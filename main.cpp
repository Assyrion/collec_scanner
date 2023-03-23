#include <QQmlApplicationEngine>
#include <QGuiApplication>
#include <QSurfaceFormat>
#include <QQuickWindow>
#include <QSqlDatabase>
#include <QSqlError>
#include <QQmlContext>
#include <QZXing.h>
#include <QSaveFile>
#include <QDebug>
#include <QDir>
#include <QThread>

#include "sqltablemodel.h"
#include "imagemanager.h"
#include "filemanager.h"
#include "commanager.h"
#include "gamedata.h"
#include "global.h"

void copyCover(QObject* dialog)
{
    // copy pics from assets folder to app folder
    QString path = QDir::currentPath()
            + QDir::separator()
            + PICPATH;
    QDir toDir(path);
    if(!toDir.exists()) toDir.mkpath(".");
    toDir.setFilter(QDir::Files | QDir::NoSymLinks);
    toDir.setNameFilters(QStringList() << "*.png");
    int local_count = toDir.entryList().count();

    QDir fromDir(REMOTE_PIC_PATH);
    fromDir.setFilter(QDir::Files | QDir::NoSymLinks);
    fromDir.setNameFilters(QStringList() << "*.png");
    int remote_count = fromDir.entryList().count();

    QMetaObject::invokeMethod(dialog, "setText", Q_ARG(QVariant, (QString::number(remote_count) + " " + QString::number(local_count))));

    if (fromDir.exists()) {
        qDebug() << local_count << remote_count;
        if (local_count < remote_count) {
            int count = 0;
            QMetaObject::invokeMethod(dialog, "setMaxValue", Q_ARG(QVariant, remote_count - local_count));
            for(const auto &fileinfo: fromDir.entryInfoList()) {
                QFile pic(fileinfo.absoluteFilePath());
                QString toPath = toDir.absolutePath()
                        + QDir::separator()
                        + fileinfo.fileName();
                if(!QFile::exists(toPath)) {
                    QMetaObject::invokeMethod(dialog, "setValue", Q_ARG(QVariant, ++count));
                    QFile::setPermissions(toPath, QFile::WriteOwner | QFile::ReadOwner);
                }
            }
        } else QMetaObject::invokeMethod(dialog, "setText", Q_ARG(QVariant, (QString::number(remote_count) + " " + QString::number(fromDir.exists()))));

    } else {
//        QMetaObject::invokeMethod(dialog, "setText", Q_ARG(QVariant, REMOTE_PIC_PATH + " n'existe pas"));
    }
}

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

    auto rootObject = engine.rootObjects().first();
    QQuickWindow* window = static_cast<QQuickWindow*>(rootObject);
    if (window) {
        // Set anti-aliasing
        QSurfaceFormat  format;
        format.setSamples(8);
        window->setFormat(format);
    }

    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");

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

    auto dialog = rootObject->findChild<QObject*>("coverDowloadingPopup");
    QMetaObject::invokeMethod(dialog, "show");

    auto thread = new QThread();
    QObject::connect(thread, &QThread::started, [=]() {
        copyCover(dialog);
        thread->quit();
    });
    QObject::connect(thread, &QThread::finished, [=]() {
//        QMetaObject::invokeMethod(dialog, "hide");
    });
    thread->start();

    return app.exec();
}
