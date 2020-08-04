#include <QQmlApplicationEngine>
#include <QGuiApplication>
#include <QSurfaceFormat>
#include <QQuickWindow>
#include <QSqlDatabase>
#include <QSqlError>
#include <QQmlContext>
#include <QZXingFilter.h>
#include <QZXing.h>
#include <QSaveFile>
#include <QDebug>
#include <QDir>

#include "sqltablemodel.h"
#include "imagemanager.h"
#include "filemanager.h"
#include "gamedata.h"
#include "global.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

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

#ifdef Q_OS_ANDROID

    // copy pics from assets folder to app folder
    QDir picPath(PICPATH_ABS);
    if(!picPath.exists()) {
        picPath.mkpath(".");
    }

    QDir fromDir("assets:/" + PICPATH);
    auto list = fromDir.entryInfoList({"*.png"}, QDir::Files);
    for(auto fileinfo: list) {
        QFile pic(fileinfo.absoluteFilePath());
        QString toPath = picPath.absolutePath()
                + QDir::separator()
                + fileinfo.fileName();
        if(!QFile::exists(toPath)) {
            pic.copy(toPath);
             QFile::setPermissions(toPath, QFile::WriteOwner | QFile::ReadOwner);
        }
    }

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

    /***** Uncomment to backup db & pic ******/

//    TO CHECK

    QDir dirCur = QDir::current();
    QString downloadPath = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
    auto dbL = dirCur.entryInfoList({DBNAME}, QDir::Files);
    for(auto fileinfo: dbL) {
        QFile from_dbf(fileinfo.absoluteFilePath());
        qDebug() << from_dbf.open(QIODevice::ReadOnly);
        QString toPath = downloadPath + QDir::separator() + fileinfo.fileName();        
        QFile to_dbf(toPath);
//        to_dbf.setDirectWriteFallback(true);
        qDebug() << to_dbf.open(QIODevice::WriteOnly);
        QByteArray array = from_dbf.readAll();
        qDebug() << to_dbf.write(array);
//        qDebug() << "commiting ; " << to_dbf.commit();
        qDebug() << to_dbf.setPermissions(QFile::WriteOwner | QFile::ReadOwner);
        from_dbf.close();
        to_dbf.close();
    }
    dirCur.cd(PICPATH);
    auto pngL = dirCur.entryInfoList({"*.png"}, QDir::Files);
    for(auto fileinfo: pngL) {
        QFile pic(fileinfo.absoluteFilePath());
        QString toPath = downloadPath
                + QDir::separator()
                + PICPATH
                + QDir::separator()
                + fileinfo.fileName();
        pic.copy(toPath);
        QFile::setPermissions(toPath, QFile::WriteOwner | QFile::ReadOwner);
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
    fileManager.registerQMLTypes();

    auto context = engine.rootContext();
    context->setContextProperty("sqlTableModel", &sqlTableModel);
    context->setContextProperty("imageManager",  &imageManager);
    context->setContextProperty("fileManager",   &fileManager);

    return app.exec();
}
