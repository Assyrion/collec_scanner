#include <QQmlApplicationEngine>
#include <QGuiApplication>
#include <QSurfaceFormat>
#include <QQuickWindow>
#include <QQmlContext>
#include <QQuickView>
#include <QSettings>
#include <QThread>
#include <QDebug>
#include <QHash>
#include <QDir>

#include <QPermission>

#include <qzxing/QZXing.h>

#include "databasemanager.h"
#include "imagemanager.h"
#include "filemanager.h"
#include "commanager.h"
#include "gamedata.h"
#include "global.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    /*************************** Init *****************************/

    QDir dataDir(Global::DATAPATH);
    if(!dataDir.exists()) dataDir.mkpath(".");

    QSettings settings(Global::DATAPATH + '/' + QString(APPNAME) + ".ini", QSettings::IniFormat);

    settings.beginGroup("mainView");
    auto collectionView = settings.value("view", Global::DEFAULT_VIEW).toInt();
    settings.endGroup();

    settings.beginGroup("platform");
    auto platformName = settings.value("name", Global::DEFAULT_PLATFORM_NAME).toString();
    auto selectedPlatforms = settings.value("selected", Global::DEFAULT_SELECTED_PLATFORM).toStringList();
    settings.endGroup();

    settings.beginGroup("params");
    QHash<QString, QVariantHash> paramHash;
    for(const QString &group : settings.childGroups()) {
        QVariantHash params;
        settings.beginGroup(group);
        for(const QString &key : settings.childKeys()) {
            params.insert(key, settings.value(key));
        }
        paramHash.insert(group, params);
        settings.endGroup();
    }
    settings.endGroup();

#ifdef Q_OS_ANDROID

    auto screen = app.primaryScreen();

#else

    auto screens = QGuiApplication::screens();
    int totalWidth = 0, totalHeight = 0;

    for(auto screen : screens) {
        QRect screenGeometry = screen->geometry();
        totalWidth  += screenGeometry.width();
        totalHeight += screenGeometry.height();
    }

    settings.beginGroup("window");
    auto windowX = settings.value("x", Global::DEFAULT_WINDOW_X).toInt();
    auto windowY = settings.value("y", Global::DEFAULT_WINDOW_Y).toInt();
    auto windowW = settings.value("w", Global::DEFAULT_WINDOW_W).toInt();
    auto windowH = settings.value("h", Global::DEFAULT_WINDOW_H).toInt();
    settings.endGroup();

    windowX = qMin(windowX, totalWidth  - windowW);
    windowY = qMin(windowY, totalHeight - windowH);

    QRect rect(windowX, windowY, windowW, windowH);

#endif

    /************************* Database *****************************/

    ComManager comManager;    
    DatabaseManager dbManager(paramHash);

    // in case of unknown database detected, we fetch it on the server
    QObject::connect(&dbManager, &DatabaseManager::unknownDatabase, [&]() {
        QQuickView *db_view = new QQuickView;
        db_view->setSource(QUrl(QStringLiteral("qrc:/download_db_view.qml")));

#ifdef Q_OS_ANDROID
        db_view->setGeometry(screen->availableGeometry());
#else
        db_view->setGeometry(rect);
#endif

        db_view->setResizeMode(QQuickView::SizeRootObjectToView);
        db_view->show();

        comManager.downloadDB();

        // remove view used for downloading DB once engine is loaded
        db_view->hide();
        db_view->deleteLater();
    });

    // initial loading of database
    if(dbManager.loadDB(platformName) < 0)
        return -1;

    /*************************** QML *******************************/

    QZXing::registerQMLTypes();
    GameDataMaker::registerQMLTypes();
    qmlRegisterType<ComManager>("ComManager", 1, 0, "ComManager");
    qmlRegisterType<FileManager>("FileManager", 1, 0, "FileManager");
    qmlRegisterType<ImageManager>("ImageManager", 1, 0, "ImageManager");

    QQmlApplicationEngine engine;

    ImageManager  imageManager;
    FileManager   fileManager;
    CoverProvider coverProvider(&imageManager);

    engine.rootContext()->setContextProperty("dbManager",
                                             &dbManager);

    engine.addImageProvider("coverProvider", &coverProvider);
    engine.setInitialProperties({
        {"comManager", QVariant::fromValue(&comManager)},
        {"fileManager", QVariant::fromValue(&fileManager)},
        {"platformName", QVariant::fromValue(platformName)},
        {"imageManager", QVariant::fromValue(&imageManager)},
        {"collectionView", QVariant::fromValue(collectionView)},
        {"selectedPlatforms", QVariant::fromValue(selectedPlatforms)}
    });

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

#ifdef Q_OS_ANDROID

#if QT_VERSION >= QT_VERSION_CHECK(6, 6, 0)
    QCameraPermission cameraPermission;
    if(qApp->checkPermission(cameraPermission) == Qt::PermissionStatus::Undetermined) {
        qApp->requestPermission(QCameraPermission{}, [](const QPermission &permission) {});
    }
#endif
    window->setGeometry(screen->availableGeometry());

#else
    window->setGeometry(rect);
#endif

    auto saveSettings = [&]() {
        settings.beginGroup("mainView");
        settings.setValue("view", rootObject->property("collectionView"));
        settings.endGroup();

        settings.beginGroup("window");
        settings.setValue("x", window->x());
        settings.setValue("y", window->y());
        settings.setValue("w", window->width());
        settings.setValue("h", window->height());
        settings.endGroup();

        settings.beginGroup("platform");
        settings.setValue("name", rootObject->property("platformName"));
        settings.setValue("selected", rootObject->property("selectedPlatforms").toStringList());
        settings.endGroup();

        settings.beginGroup("params");
        auto keys = paramHash.keys();
        for(const QString &key : keys) {
            settings.beginGroup(key);
            for(const QString& paramKey : paramHash[key].keys()) {
                settings.setValue(paramKey, paramHash[key][paramKey]);
            }
            settings.endGroup();
        }
        settings.endGroup();

        settings.sync();
    };

    QThread dlCoversThread;

    auto dialog = rootObject->findChild<QObject*>("coverProcessingPopup");
    comManager.setProgressDialog(dialog);

    QObject::connect(dialog, SIGNAL(aboutToHide()), dbManager.currentProxyModel(), SLOT(invalidate()));
    QObject::connect(dialog, SIGNAL(aboutToHide()), &dlCoversThread, SLOT(quit()));
    QObject::connect(&dbManager, SIGNAL(databaseChanged()), &dlCoversThread, SLOT(start()));
    QObject::connect(&dlCoversThread, &QThread::started, &comManager, [&]() {
        auto platformName = rootObject->property("platformName").toString();
        comManager.downloadCovers(platformName);
    });

    comManager.moveToThread(&dlCoversThread);

    QObject::connect(&app, &QGuiApplication::aboutToQuit, [&](){
        saveSettings();
        dlCoversThread.quit();
    });

#ifdef Q_OS_ANDROID
    QObject::connect(&app, &QGuiApplication::applicationStateChanged,
                     [&](Qt::ApplicationState state){
                         if(state != Qt::ApplicationActive) {
                             saveSettings();
                         }
                     });
#endif

    // initial downloading of covers
    dlCoversThread.start();

    return app.exec();
}
