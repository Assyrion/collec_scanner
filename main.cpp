#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QStandardPaths>
#include <QZXingFilter.h>
#include <QZXing.h>
#include <QDebug>

#include "filemanager.h"
#include "dbmanager.h"

int main(int argc, char *argv[])
{
//    QImage imageToDecode(QStandardPaths::writableLocation(QStandardPaths::DesktopLocation) + "/IMG_00000003.jpg");
//    QZXing decoder;
//    decoder.setDecoder( QZXing::DecoderFormat_EAN_13 );
//    QString result = decoder.decodeImage(imageToDecode/*, 1000, 1000, true*/);
//    qDebug() << result;

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QZXing::registerQMLTypes();

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    FileManager fileManager;
    DBManager   dbManager;

    engine.rootContext()->setContextProperty("fileManager", &fileManager);
    engine.rootContext()->setContextProperty("dbManager",   &dbManager);

    return app.exec();
}
