#include <QQmlApplicationEngine>

#include <QGuiApplication>
#include <QSurfaceFormat>
#include <QQuickWindow>
#include <QSqlDatabase>
#include <QQmlContext>
#include <QTranslator>
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

    /*************************** QML *******************************/

    GameDataMaker::registerQMLTypes();
    QZXing::registerQMLTypes();

    QQmlApplicationEngine engine;

    SqlTableModel sqlTableModel;
    ImageManager  imageManager;
    ComManager    comManager;
    FileManager   fileManager;

    fileManager.registerQMLTypes();

    auto context = engine.rootContext();
    context->setContextProperty("sqlTableModel", &sqlTableModel);
    context->setContextProperty("imageManager",  &imageManager);
    context->setContextProperty("comManager",    &comManager);
    context->setContextProperty("fileManager",   &fileManager);

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

    auto dialog = rootObject->findChild<QObject*>("coverProcessingPopup");
    comManager.setProgressDialog(dialog);

    /************************* Database *****************************/

    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");

    //    QFile::remove(DB_PATH_ABS_NAME); // uncomment if needed for tests

    if(!QFile::exists(DB_PATH_ABS_NAME)) {
        comManager.downloadDB();
    }

//        db.close();
    db.setDatabaseName(DB_PATH_ABS_NAME);
    if (!db.open()) {
        qDebug() << "Error: connection with database fail" << db.lastError();
        return -1;
    }


    comManager.downloadCovers();

    return app.exec();
}
