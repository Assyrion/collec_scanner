#include <QQmlApplicationEngine>

#include <QGuiApplication>
#include <QSurfaceFormat>
#include <QSignalMapper>
#include <QQuickWindow>
#include <QSqlDatabase>
#include <QQmlContext>
#include <QTranslator>
#include <QQuickView>
#include <QSqlError>
#include <QSaveFile>
#include <QSettings>
#include <QZXing.h>
#include <QThread>
#include <QDebug>
#include <QDir>

#include "sortfilterproxymodel.h"
#include "databasemanager.h"
#include "sqltablemodel.h"
#include "imagemanager.h"
#include "filemanager.h"
#include "commanager.h"
#include "gamedata.h"
#include "global.h"

#include <QSqlTableModel>
#include <QHash>

QHash<QString, SqlTableModel*> modelHash;

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    /*************************** Init *****************************/

    QDir dataDir(Global::DATAPATH);
    if(!dataDir.exists()) dataDir.mkpath(".");

    QSettings settings(Global::DATAPATH + QDir::separator() + QString(APPNAME) + ".ini", QSettings::IniFormat);

    if(settings.allKeys().isEmpty()) {
        settings.setValue("sqlTableModel/orderBy", 1);
        settings.setValue("sqlTableModel/sortOrder", 0);
        settings.setValue("sqlTableModel/titleFilter", "");
        settings.setValue("sqlTableModel/ownedFilter", 2);
        settings.setValue("sqlTableModel/essentialsFilter", true);
        settings.setValue("sqlTableModel/essentialsOnly", false);
        settings.setValue("sqlTableModel/platinumFilter", true);
        settings.setValue("sqlTableModel/platinumOnly", false);
        settings.setValue("mainView/view", 0);
        settings.setValue("window/x", 50);
        settings.setValue("window/y", 50);
        settings.setValue("window/w", 512);
        settings.setValue("window/h", 773);
        settings.setValue("platform/name", "ps3");
    }

    settings.beginGroup("sqlTableModel");
    auto orderBy = settings.value("orderBy").toInt();
    auto sortOrder = settings.value("sortOrder").toInt();
    auto titleFilter = settings.value("titleFilter").toString();
    auto ownedFilter = settings.value("ownedFilter", 2).toInt();
    auto essentialsFilter = settings.value("essentialsFilter", true).toBool();
    auto essentialsOnly = settings.value("essentialsOnly", false).toBool();
    auto platinumFilter = settings.value("platinumFilter", true).toBool();
    auto platinumOnly = settings.value("platinumOnly", false).toBool();
    settings.endGroup();

    settings.beginGroup("mainView");
    auto collectionView = settings.value("view").toInt();
    settings.endGroup();

    settings.beginGroup("platform");
    auto platformName = settings.value("name", "ps3").toString();
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
    auto windowX = settings.value("x").toInt();
    auto windowY = settings.value("y").toInt();
    auto windowW = settings.value("w").toInt();
    auto windowH = settings.value("h").toInt();
    settings.endGroup();

    windowX = qMin(windowX, totalWidth  - windowW);
    windowY = qMin(windowY, totalHeight - windowH);

    QRect rect(windowX, windowY, windowW, windowH);

#endif

    /************************* Database *****************************/

    ComManager comManager;

    auto downloadDB = [&]() {
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
    };

    DatabaseManager dbManager;
    QObject::connect(&dbManager, &DatabaseManager::unknownDatabase, downloadDB);

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

    SortFilterProxyModel* sortFilterProxyModel = new SortFilterProxyModel(orderBy, sortOrder,
                                                                          titleFilter, ownedFilter,
                                                                          essentialsFilter, platinumFilter,
                                                                          essentialsOnly, platinumOnly);
    sortFilterProxyModel->setSourceModel(dbManager.currentSQLModel());
    engine.rootContext()->setContextProperty("sortFilterProxyModel",
                                             sortFilterProxyModel);
    engine.rootContext()->setContextProperty("dbManager",
                                             &dbManager);

    engine.addImageProvider("coverProvider", &coverProvider);
    engine.setInitialProperties({
        {"comManager", QVariant::fromValue(&comManager)},
        {"fileManager", QVariant::fromValue(&fileManager)},
        {"platformName", QVariant::fromValue(platformName)},
        {"imageManager", QVariant::fromValue(&imageManager)},
        {"collectionView", QVariant::fromValue(collectionView)}
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
    window->setGeometry(screen->availableGeometry());
#else
    window->setGeometry(rect);
#endif

    auto saveSettings = [&]() {

        settings.beginGroup("sqlTableModel");
        settings.setValue("orderBy", sortFilterProxyModel->getOrderBy());
        settings.setValue("sortOrder", sortFilterProxyModel->getSortOrder());
        settings.setValue("titleFilter", sortFilterProxyModel->getTitleFilter());
        settings.setValue("ownedFilter", sortFilterProxyModel->getOwnedFilter());
        settings.setValue("essentialsFilter", sortFilterProxyModel->getEssentialsFilter());
        settings.setValue("essentialsOnly", sortFilterProxyModel->getEssentialsOnly());
        settings.setValue("platinumFilter", sortFilterProxyModel->getPlatinumFilter());
        settings.setValue("platinumOnly", sortFilterProxyModel->getPlatinumOnly());
        settings.endGroup();

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
        settings.endGroup();

        settings.sync();
    };


    QSignalMapper sm;
    sm.setMapping(rootObject, rootObject); // dummy mapping

    QThread thread;

    auto dialog = rootObject->findChild<QObject*>("coverProcessingPopup");
    comManager.setProgressDialog(dialog);

    QObject::connect(dialog, SIGNAL(aboutToHide()), sortFilterProxyModel, SLOT(invalidate()));
    QObject::connect(dialog, SIGNAL(aboutToHide()), &thread, SLOT(quit()));
    QObject::connect(&thread, &QThread::started, &comManager, [&]() {
        auto platformName = rootObject->property("platformName").toString();
        comManager.downloadCovers(platformName);
    });
    QObject::connect(rootObject, SIGNAL(platformNameChanged()), &sm, SLOT(map()));
    QObject::connect(&sm, &QSignalMapper::mappedObject, [&](QObject* obj){
        auto platformName = obj->property("platformName").toString();
        dbManager.loadDB(platformName);
        sortFilterProxyModel->setSourceModel(dbManager.currentSQLModel());
        sortFilterProxyModel->resetFilter();
        thread.start();
    });

    comManager.moveToThread(&thread);

#ifdef Q_OS_ANDROID
        // Because there is now way to catch aboutToClose signal with gesture navigation on Android
    QObject::connect(&app, &QGuiApplication::applicationStateChanged,
                     [&](Qt::ApplicationState state){
                         if(state != Qt::ApplicationActive) {
                             saveSettings();
                         }
                     });
#else
    QObject::connect(&app, &QGuiApplication::aboutToQuit, [&](){
        saveSettings();
        thread.quit();
    });
#endif

    thread.start();

    return app.exec();
}
