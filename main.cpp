#include <QQmlApplicationEngine>
#include <QGuiApplication>
#include <QSurfaceFormat>
#include <QAuthenticator>
#include <QQuickWindow>
#include <QSqlDatabase>
#include <QSqlError>
#include <QQmlContext>
#include <QZXing.h>
#include <QSaveFile>
#include <QDebug>
#include <QDir>

#include "sqltablemodel.h"
#include "imagemanager.h"
#include "filemanager.h"
#include "commanager.h"
#include "gamedata.h"
#include "global.h"


int main(int argc, char *argv[])
{
    GameDataMaker::registerQMLTypes();
    QZXing::registerQMLTypes();

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    QQuickWindow* window = static_cast<QQuickWindow*>(engine.rootObjects().first());
    if (window) {
        // Set anti-aliasing
        QSurfaceFormat  format;
        format.setSamples(8);
        window->setFormat(format);
    }

    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");

    // copy pics from assets folder to app folder
    QDir picPath(PICPATH_ABS);
    if(!picPath.exists()) {
        picPath.mkpath(".");
    }

    picPath.setFilter(QDir::Files | QDir::NoSymLinks);
    picPath.setNameFilters(QStringList() << "*.png");
    int local_count = picPath.entryList().count();
    qDebug() << "local_count : " << local_count;

    QDir fromDir(REMOTE_PIC_PATH);

    QAuthenticator auth;
    auth.setUser(REMOTE_USER);
    auth.setPassword(REMOTE_PWD);

    if (!auth.isNull()) {
        fromDir.setSorting(QDir::Name);
        fromDir.setFilter(QDir::Files | QDir::NoSymLinks);
        fromDir.setNameFilters(QStringList() << "*.png");
        int remote_count = fromDir.entryList().count();
        qDebug() << "remote_count : " << remote_count;

        if (fromDir.exists() && local_count < remote_count) {
            for(const auto &fileinfo: fromDir.entryInfoList()) {
                QFile pic(fileinfo.absoluteFilePath());
                qDebug() << fileinfo.absoluteFilePath();
                QString toPath = picPath.absolutePath()
                        + QDir::separator()
                        + fileinfo.fileName();
                if(!QFile::exists(toPath)) {
                    qDebug() << pic.copy(toPath);
                    QFile::setPermissions(toPath, QFile::WriteOwner | QFile::ReadOwner);
                }
            }
        }
    }

#ifdef Q_OS_ANDROID


    // copy database file from assets folder to app folder
    QFile dfile("assets:/" + DBNAME);
    if (dfile.exists()) {
        if(!QFile::exists(DB_PATH_ABS_NAME)) {
            dfile.copy(DB_PATH_ABS_NAME);
            QFile::setPermissions(DB_PATH_ABS_NAME, QFile::WriteOwner | QFile::ReadOwner);
        }
    } else {
        return -1;
    }
#endif

    db.close();
    db.setDatabaseName(DB_PATH_ABS_NAME);
    if (!db.open()) {
        qDebug() << "Error: connection with database fail" << db.lastError();
        return -1;
    }

    SqlTableModel sqlTableModel;
    ImageManager  imageManager;
    FileManager   fileManager;
    ComManager    comManager;
    fileManager.registerQMLTypes();

    auto context = engine.rootContext();
    context->setContextProperty("sqlTableModel", &sqlTableModel);
    context->setContextProperty("imageManager",  &imageManager);
    context->setContextProperty("fileManager",   &fileManager);
    context->setContextProperty("comManager",    &comManager);

    return app.exec();
}
