#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QStandardPaths>
#include <QZXingFilter.h>
#include <QZXing.h>
#include <QDebug>

#include "filemanager.h"

int main(int argc, char *argv[])
{
//    QImage imageToDecode(QStandardPaths::writableLocation(QStandardPaths::DesktopLocation) + "/DSC_0062.JPG");
//    QZXing decoder;
//    decoder.setDecoder( QZXing::DecoderFormat_EAN_13 );
//    QString result = decoder.decodeImage(imageToDecode/*, 1000, 1000, true*/);
//    qDebug() << result;

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
//    QZXing::registerQMLTypes();
    qmlRegisterType<QZXing>("QZXing", 2, 3, "QZXing");
    qmlRegisterType<QZXingFilter>("QZXing", 2, 3, "QZXingFilter");
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    FileManager fileManager;
    engine.rootContext()->setContextProperty("fileManager", &fileManager);

    return app.exec();
}
