#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QStandardPaths>
#include <QZXingFilter.h>
#include <QZXing.h>
#include <QDebug>

#ifdef Q_OS_ANDROID
#include <QAndroidJniObject>
#include <QAndroidJniEnvironment>
#include <QtAndroid>
#endif

#include "imagemanager.h"
#include "filemanager.h"
#include "dbmanager.h"
#include "gamedata.h"

int main(int argc, char *argv[])
{
#ifdef Q_OS_ANDROID
//    auto permissionCallback = [](const auto permissionResult) {
//        for(const auto &key : permissionResult.keys()) {
//            // Permission 0 = granted, 1 = denied
//            qDebug() << "Permission:" << key << "granted?" << !static_cast<bool>(permissionResult.value(key));
//        }
//    };
//    QtAndroid::requestPermissions({"android.permission.WRITE_EXTERNAL_STORAGE"}, permissionCallback);
//    QtAndroid::requestPermissionsSync({"android.permission.WRITE_EXTERNAL_STORAGE"});
//    QAndroidJniObject javaCall = QAndroidJniObject::fromString("android.permission.WRITE_EXTERNAL_STORAGE");
#endif

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QZXing::registerQMLTypes();
    GameData::registerQMLTypes();

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    ImageManager imageManager;
    FileManager  fileManager;
    DBManager    dbManager;

    engine.rootContext()->setContextProperty("imageManager", &imageManager);
    engine.rootContext()->setContextProperty("fileManager", &fileManager);
    engine.rootContext()->setContextProperty("dbManager",   &dbManager);

    return app.exec();
}
