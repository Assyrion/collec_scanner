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

    /************************* Database *****************************/

    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName(DB_PATH_ABS_NAME);

    //    QFile::remove(DB_PATH_ABS_NAME); // uncomment if needed for tests

    ComManager comManager;

    // checking if needed to download DB
    if(!QFile::exists(DB_PATH_ABS_NAME)) {

        QQuickView *view = new QQuickView;
        view->setSource(QUrl(QStringLiteral("qrc:/download_db_view.qml")));

#ifdef Q_OS_ANDROID
        view->setGeometry(screen->availableGeometry());
#else
        view->resize(size);
#endif

        view->setResizeMode(QQuickView::SizeRootObjectToView);
        view->show();

        comManager.downloadDB();

        // remove view used for downloading DB once engine is loaded
        view->hide();
        view->deleteLater();
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

    SqlTableModel sqlTableModel;
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
        {"sqlTableModel", QVariant::fromValue(&sqlTableModel)}
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

    auto dialog = rootObject->findChild<QObject*>("coverProcessingPopup");
    comManager.setProgressDialog(dialog);

    QThread thread;
    QObject::connect(&thread, &QThread::started, &comManager, &ComManager::downloadCovers);
    QObject::connect(&app, &QGuiApplication::aboutToQuit, [&thread](){
        thread.quit();
        thread.wait();
    });
    comManager.moveToThread(&thread);

    thread.start();

    return app.exec();
}
