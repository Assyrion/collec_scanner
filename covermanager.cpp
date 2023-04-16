#include <QNetworkAccessManager>
#include <QRegularExpression>
#include <QGuiApplication>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QEventLoop>

#include "covermanager.h"
#include "global.h"

const QRegularExpression re("href=\"([^\"]+\\.png)\">.*?(\\d{4}-\\d{2}-\\d{2}\\s\\d{2}:\\d{2})");

CoverManager::CoverManager(QObject *parent)
    : QObject{parent}
{

}

void CoverManager::uploadCovers()
{
    qDebug() << "covers uploading";
}


void CoverManager::downloadCovers(QObject* dialog)
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
