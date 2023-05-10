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

    QScreen *screen;

#ifdef Q_OS_ANDROID
    screen = QGuiApplication::primaryScreen();
#else
    screen = app.screens().at(1);
    QSize size(screen->size().width() / 5,
               screen->size().height() / 2 + 40);
#endif

    /************************* Translator ***************************/

    // Détermine la locale actuelle
    QString locale = QLocale::system().name();

    // Crée un objet traducteur pour cette locale
    QTranslator translator;
    bool ret = translator.load(QString(":/translations/%1").arg(locale));
    if(ret) {
        // Installe le traducteur dans l'application
        QCoreApplication::installTranslator(&translator);
    }

    /************************* Database *****************************/

    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");

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

    db.setDatabaseName(DB_PATH_ABS_NAME);
    if (!db.open()) {
        qDebug() << "Error: connection with database fail" << db.lastError();
        return -1;
    }

    /*************************** QML *******************************/

    SqlTableModel sqlTableModel;
    ImageManager  imageManager;
    FileManager   fileManager;

    fileManager.registerQMLTypes();
    GameDataMaker::registerQMLTypes();
    QZXing::registerQMLTypes();

    QQmlApplicationEngine engine;
    auto context = engine.rootContext();

    context->setContextProperty("imageManager",  &imageManager);
    context->setContextProperty("comManager",    &comManager);
    context->setContextProperty("fileManager",   &fileManager);
    context->setContextProperty("sqlTableModel", &sqlTableModel);

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
    comManager.downloadCovers();

    return app.exec();
}
