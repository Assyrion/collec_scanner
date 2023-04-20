#include <QNetworkAccessManager>
#include <QRegularExpression>
#include <QGuiApplication>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QEventLoop>
#include <QHttpPart>

#include "covermanager.h"
#include "global.h"

const QRegularExpression re("href=\"([^\"]+\\.png)\">.*?(\\d{4}-\\d{2}-\\d{2}\\s\\d{2}:\\d{2})");

CoverManager::CoverManager(QObject *parent)
    : QObject{parent}
{
    m_coversToUploadFile.setFileName(PICPATH_ABS + "covers_to_upload.txt");
}

CoverManager::~CoverManager()
{
    if(m_coversToUploadFile.isOpen())
        m_coversToUploadFile.close();
}

void CoverManager::downloadCovers()
{
    QMetaObject::invokeMethod(m_progressDialog, "show");

    QDir toDir(PICPATH_ABS);
    if(!toDir.exists()) toDir.mkpath(".");
    toDir.setFilter(QDir::Files | QDir::NoSymLinks);
    toDir.setNameFilters(QStringList() << "*.png");
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

            QMetaObject::invokeMethod(m_progressDialog, "setMaxValue", Q_ARG(QVariant, remote_count));

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

                                QMetaObject::invokeMethod(m_progressDialog, "setValue", Q_ARG(QVariant, ++count));
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

    QMetaObject::invokeMethod(m_progressDialog, "hide");
}


bool CoverManager::uploadToServer(const QString& fileName)
{
    // Ouvrir le fichier PNG
    QFile file(PICPATH_ABS + fileName);
    if (!file.open(QIODevice::ReadOnly)) {
        qDebug() << "Impossible d'ouvrir le fichier";
        return false;
    }

    QMetaObject::invokeMethod(m_progressDialog, "show");

    QUrl url(REMOTE_UPLOAD_SCRIPT);
    QNetworkRequest request(url);

    QHttpPart filePart;
    filePart.setHeader(QNetworkRequest::ContentTypeHeader, QVariant("image/png"));
    filePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"file\"; filename=\"" + fileName + "\""));
    filePart.setHeader(QNetworkRequest::ContentLengthHeader, file.size());
    filePart.setBodyDevice(&file);

    QHttpMultiPart multiPart(QHttpMultiPart::FormDataType);
    multiPart.append(filePart);

    // Envoyer la requête HTTP POST
    QNetworkAccessManager manager;
    QNetworkReply * reply = manager.post(request, &multiPart);

    // Connexion du signal uploadProgress() pour afficher la progression de l'envoi
    QObject::connect(reply, &QNetworkReply::uploadProgress, [&](qint64 bytesSent, qint64 bytesTotal) {
        qDebug() << "Envoyé :" << bytesSent << "sur" << bytesTotal;
    });

    QEventLoop loop;
    QObject::connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    loop.exec(); // Attendre la fin de la réponse

    bool ret = false;
    QByteArray response = reply->readAll();
    // Vérifier la réponse du serveur
    if (reply->error() != QNetworkReply::NoError) {
        qDebug() << "Réponse du serveur: " << response;
                ret = false;
    } else {
        qDebug() << "Fichier envoyé avec succès !" << response;
                ret = true;
    }

    // Nettoyer
    file.close();
    reply->deleteLater();

    return ret;
}

void CoverManager::uploadCovers()
{
    QMetaObject::invokeMethod(m_progressDialog, "show");

    m_coversToUploadFile.open(QIODevice::ReadOnly | QIODevice::Text);

    QTextStream ts(&m_coversToUploadFile);
    ts.seek(0);

    QString all(ts.readAll());
    QStringList sl(all.split('\n'));

    QMetaObject::invokeMethod(m_progressDialog, "setMaxValue", Q_ARG(QVariant, sl.count()));
    int count = 0;

    foreach (auto s, sl) {
        if(!s.isEmpty() && uploadToServer(s)) {

            QMetaObject::invokeMethod(m_progressDialog, "setValue", Q_ARG(QVariant, ++count));

            sl.removeOne(s);
        }
    }

    m_coversToUploadFile.close();

    m_coversToUploadFile.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Truncate);

    foreach (auto s, sl) {
        if(!s.isEmpty())
            ts << s << '\n';
    }

    m_coversToUploadFile.close();

    QMetaObject::invokeMethod(m_progressDialog, "hide");
}

void CoverManager::handleBackCover(const QString &tag)
{
    m_coversToUploadFile.open(QIODevice::ReadWrite | QIODevice::Text | QIODevice::Append);
    appendToList(tag + "_back.png");
    m_coversToUploadFile.close();
}

void CoverManager::handleFrontCover(const QString &tag)
{
    m_coversToUploadFile.open(QIODevice::ReadWrite | QIODevice::Text | QIODevice::Append);
    appendToList(tag + "_front.png");
    m_coversToUploadFile.close();
}

void CoverManager::setProgressDialog(QObject *dialog)
{
    m_progressDialog = dialog;
}

void CoverManager::appendToList(const QString &fileName)
{
    QTextStream ts(&m_coversToUploadFile);
    ts.seek(0);

    QString all(ts.readAll());
    QStringList sl(all.split('\n'));
    if(!sl.contains(fileName)) {
        ts << fileName << '\n';
    }
}

