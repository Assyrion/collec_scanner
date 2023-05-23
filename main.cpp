#include <QQmlApplicationEngine>

#include <QGuiApplication>
#include <QSurfaceFormat>
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

#include "sqltablemodel.h"
#include "imagemanager.h"
#include "filemanager.h"
#include "commanager.h"
#include "gamedata.h"
#include "global.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    auto screen = app.primaryScreen();

    /*************************** Init *****************************/

    QDir dataDir(DATAPATH);
    if(!dataDir.exists()) dataDir.mkpath(".");

    QSettings settings(DATAPATH + QDir::separator() + QString(APPNAME) + ".ini", QSettings::IniFormat);

    if(settings.allKeys().isEmpty()) {
        settings.setValue("sqlTableModel/orderBy", 1);
        settings.setValue("sqlTableModel/sortOrder", 0);
        settings.setValue("sqlTableModel/titleFilter", "");
        settings.setValue("sqlTableModel/ownedFilter", 2);
        settings.setValue("mainView/view", 0);
        settings.setValue("window/x", screen->geometry().width()/4);
        settings.setValue("window/y", screen->geometry().height()/4);
        settings.setValue("window/w", 512);
        settings.setValue("window/h", 773);
    }

    settings.beginGroup("sqlTableModel");
    auto orderBy = settings.value("orderBy").toInt();
    auto sortOrder = settings.value("sortOrder").toInt();
    auto titleFilter = settings.value("titleFilter").toString();
    auto ownedFilter = settings.value("ownedFilter", 2).toInt();
    settings.endGroup();

    settings.beginGroup("mainView");
    auto collectionView = settings.value("view").toInt();
    settings.endGroup();

    settings.beginGroup("window");
    auto windowX = settings.value("x").toInt();
    auto windowY = settings.value("y").toInt();
    auto windowW = settings.value("w").toInt();
    auto windowH = settings.value("h").toInt();
    settings.endGroup();

#ifndef Q_OS_ANDROID
    QRect rect(windowX, windowY, windowW, windowH);
#endif

    /************************* Database *****************************/

    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName(DB_PATH_ABS_NAME);

//    QFile::remove(DB_PATH_ABS_NAME); // uncomment if needed for tests

    ComManager comManager;

    // checking if needed to download DB
    if(!QFile::exists(DB_PATH_ABS_NAME)) {

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
    }

    if (!db.open()) {
        qDebug() << "Error: connection with database fail" << db.lastError();
        return -1;
    } else if(!db.tables().contains("games")) { // wrong database
        qDebug() << "Error: database corrupted";
        db.close();
        QFile::remove(DB_PATH_ABS_NAME);
        return -1;
    }

    /*************************** QML *******************************/

    GameDataMaker::registerQMLTypes();
    QZXing::registerQMLTypes();

    QQmlApplicationEngine engine;

    SqlTableModel sqlTableModel(orderBy, sortOrder, titleFilter, ownedFilter);
    ImageManager  imageManager;
    FileManager   fileManager;

    qmlRegisterType<ComManager>("ComManager", 1, 0, "ComManager");
    qmlRegisterType<FileManager>("FileManager", 1, 0, "FileManager");
    qmlRegisterType<ImageManager>("ImageManager", 1, 0, "ImageManager");
    qmlRegisterType<SqlTableModel>("SQLTableModel", 1, 0, "SQLTableModel");

    engine.setInitialProperties({
        {"comManager", QVariant::fromValue(&comManager)},
        {"fileManager", QVariant::fromValue(&fileManager)},
        {"imageManager", QVariant::fromValue(&imageManager)},
        {"sqlTableModel", QVariant::fromValue(&sqlTableModel)},
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
        settings.setValue("orderBy", sqlTableModel.getOrderBy());
        settings.setValue("sortOrder", sqlTableModel.getSortOrder());
        settings.setValue("titleFilter", sqlTableModel.getTitleFilter());
        settings.setValue("ownedFilter", sqlTableModel.getOwnedFilter());
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
    };

#ifdef Q_OS_ANDROID
    // Because there is now way to catch aboutToClose signal with gesture navigation on Android
    QObject::connect(&app, &QGuiApplication::applicationStateChanged,
                     [&](Qt::ApplicationState state){
                         if(state != Qt::ApplicationActive) {
                             saveSettings();
                         }
                     });
#endif

    auto dialog = rootObject->findChild<QObject*>("coverProcessingPopup");
    comManager.setProgressDialog(dialog);

    QThread thread;
    QObject::connect(dialog, SIGNAL(aboutToHide()), &thread, SLOT(quit()));
    QObject::connect(&thread, &QThread::started, &comManager, &ComManager::downloadCovers);
    QObject::connect(&app, &QGuiApplication::aboutToQuit, [&](){
        saveSettings();
        thread.quit();
    });
    comManager.moveToThread(&thread);

    thread.start();

    return app.exec();
}
