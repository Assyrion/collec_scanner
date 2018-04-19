#include <QQmlApplicationEngine>
#include <QGuiApplication>
#include <QSurfaceFormat>
#include <QQuickWindow>
#include <QSqlDatabase>
#include <QQmlContext>
#include <QZXingFilter.h>
#include <QZXing.h>
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

    QQuickWindow* window = (QQuickWindow*) engine.rootObjects().first();
    if (window) {
        // Set anti-aliasing
        QSurfaceFormat  format;
        format.setSamples(8);
        window->setFormat(format);
    }

    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");

#ifdef Q_OS_ANDROID    
    QDir picPath(PICPATH_ABS);
    if(!picPath.exists()) {
        picPath.mkdir(".");
    }
    QDir fromDir("assets:/" + PICPATH);
    auto list = fromDir.entryInfoList({"*.png"}, QDir::Files);
    for(auto fileinfo: list) {
        QFile pic(fileinfo.absoluteFilePath());
        QString toPath = PICPATH_ABS + QDir::separator() + fileinfo.fileName();
        if(!QFile::exists(toPath)) {
            pic.copy(toPath);
            QFile::setPermissions(toPath, QFile::WriteOwner | QFile::ReadOwner);
        }
    }

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
    db.setDatabaseName(DB_PATH_ABS_NAME);
    if (!db.open()) {
        qDebug() << "Error: connection with database fail";
        return -1;
    }

    SqlTableModel sqlTableModel;
    ImageManager  imageManager;
    FileManager   fileManager;

    auto context = engine.rootContext();
    context->setContextProperty("sqlTableModel", &sqlTableModel);
    context->setContextProperty("imageManager",  &imageManager);
    context->setContextProperty("fileManager",   &fileManager);

    return app.exec();
}
