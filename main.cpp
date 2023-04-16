#include <QQmlApplicationEngine>
#include <QNetworkAccessManager>
#include <QRegularExpression>
#include <QGuiApplication>
#include <QNetworkRequest>
#include <QSurfaceFormat>
#include <QNetworkReply>
#include <QQuickWindow>
#include <QSqlDatabase>
#include <QSqlError>
#include <QQmlContext>
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

const QRegularExpression re("href=\"([^\"]+\\.png)\">.*?(\\d{4}-\\d{2}-\\d{2}\\s\\d{2}:\\d{2})");

void downloadCovers(QObject* dialog)
{
    QDir toDir(PICPATH_ABS);
    if(!toDir.exists()) toDir.mkpath(".");
    toDir.setFilter(QDir::Files | QDir::NoSymLinks);
    toDir.setNameFilters(QStringList() << "*.png");
    int local_count = toDir.entryList().count();
    int count = 0;

    QUrl url(REMOTE_PIC_PATH);
    QNetworkAccessManager manager;
    QNetworkRequest request(url);
    QNetworkReply *reply = manager.get(request);

    QEventLoop loop;

    QObject::connect(reply, &QNetworkReply::finished, [&]() {
        if (reply->error() != QNetworkReply::NoError) {
            qDebug() << "Error:" << reply->errorString();
        } else {
            QString data = QString::fromUtf8(reply->readAll());
            int remote_count = data.count(".png</a>");

            QMetaObject::invokeMethod(dialog, "setMaxValue", Q_ARG(QVariant, remote_count - local_count));

            QStringList htmlLineList = data.split("\n", Qt::SkipEmptyParts);

            for (const QString& htmlLine : htmlLineList) {
                QRegularExpressionMatch match = re.match(htmlLine);

                if(match.hasMatch()) {
                    QString remoteFileName(match.captured(1));
                    QDateTime remoteCreationDate(QDateTime::fromString(match.captured(2), Qt::ISODate));

                    QString localPath = toDir.absolutePath()
                                     + QDir::separator()
                                     + remoteFileName;

                    QDateTime localModifiedDate(remoteCreationDate);

                    if(QFile::exists(localPath)) {
                        QFileInfo localFileInfo(localPath);
                        localModifiedDate = localFileInfo.lastModified();
                    }

                    if(!QFile::exists(localPath) || (remoteCreationDate > localModifiedDate)) {
                        QUrl fileUrl(url.toString() + remoteFileName);
                        QNetworkRequest fileRequest(fileUrl);
                        QNetworkReply *fileReply = manager.get(fileRequest);
                        while (!fileReply->isFinished()) {
                            qApp->processEvents();
                        }
                        // Vérification du code de réponse
                        if (fileReply->error() == QNetworkReply::NoError) {
                            // Enregistrement du fichier sur le disque
                            QFile file(localPath);
                            if (file.open(QIODevice::WriteOnly)) {
                                file.setPermissions(QFile::WriteOwner | QFile::ReadOwner);
                                file.write(fileReply->readAll());
                                file.close();

                                QMetaObject::invokeMethod(dialog, "setValue", Q_ARG(QVariant, ++count));
                            }
                        } else {
                            // Traitement de l'erreur
                            qDebug() << "Erreur lors du téléchargement du fichier" << remoteFileName << ":" << fileReply->errorString();
                        }
                        fileReply->deleteLater();
                    }
                }
            }
        }
        reply->deleteLater();
        loop.quit();
    });

    loop.exec();
}

int main(int argc, char *argv[])
{
    GameDataMaker::registerQMLTypes();
    QZXing::registerQMLTypes();

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
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

    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");

#ifdef Q_OS_ANDROID

    // copy database file from assets folder to app folder
    QFile dfile("assets:/" + DBNAME);
    if (dfile.exists()) {
        if(!QFile::exists(DB_PATH_ABS_NAME)) {
            dfile.copy(DB_PATH_ABS_NAME);
            QFile::setPermissions(DB_PATH_ABS_NAME, QFile::WriteOwner | QFile::ReadOwner);
        }
    } else {
        return -1;
    }

#endif

    db.close();
    db.setDatabaseName(DB_PATH_ABS_NAME);
    if (!db.open()) {
        qDebug() << "Error: connection with database fail" << db.lastError();
        return -1;
    }

    SqlTableModel sqlTableModel;
    ImageManager  imageManager;
    FileManager   fileManager;

    fileManager.registerQMLTypes();

    auto context = engine.rootContext();
    context->setContextProperty("sqlTableModel", &sqlTableModel);
    context->setContextProperty("imageManager",  &imageManager);
    context->setContextProperty("fileManager",   &fileManager);

#ifdef Q_OS_ANDROID
    ComManager comManager;
    context->setContextProperty("comManager", &comManager);
#endif

    auto dialog = rootObject->findChild<QObject*>("coverDowloadingPopup");

    QMetaObject::invokeMethod(dialog, "show");
    downloadCovers(dialog);
    QMetaObject::invokeMethod(dialog, "hide");

    return app.exec();
}
