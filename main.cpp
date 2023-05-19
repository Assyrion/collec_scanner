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

    /*************************** Init *****************************/

#ifdef Q_OS_ANDROID
    QScreen *screen;
    screen = QGuiApplication::primaryScreen();
#else
    QSize size(512, 773);
#endif

    QDir dataDir(DATAPATH);
    if(!dataDir.exists()) dataDir.mkpath(".");

    QSettings settings(DATAPATH + QDir::separator() + QString(APPNAME) + ".ini", QSettings::IniFormat);

    if(settings.allKeys().isEmpty()) {
        settings.setValue("sqlTableModel/orderBy", 1);
        settings.setValue("sqlTableModel/sortOrder", 0);
        settings.setValue("sqlTableModel/filter", "");
        settings.setValue("mainView/view", 0);
    }

    settings.beginGroup("sqlTableModel");
    auto orderBy = settings.value("orderBy").toInt();
    auto sortOrder = settings.value("sortOrder").toInt();
    auto filter = settings.value("filter").toString();
    settings.endGroup();

    settings.beginGroup("mainView");
    auto collectionView = settings.value("view").toInt();
    settings.endGroup();

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
        view->setGeometry(screen->availableGeometry());
#else
        db_view->resize(size);
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

    SqlTableModel sqlTableModel(orderBy, sortOrder, filter);
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
    window->resize(size);
#endif

    auto saveSettings = [&]() {
        settings.beginGroup("sqlTableModel");
        settings.setValue("orderBy", sqlTableModel.getOrderBy());
        settings.setValue("sortOrder", sqlTableModel.getSortOrder());
        settings.setValue("filter", sqlTableModel.getFilter());
        settings.endGroup();

        settings.beginGroup("mainView");
        settings.setValue("view", rootObject->property("collectionView"));
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
