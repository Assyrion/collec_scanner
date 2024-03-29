#include <QNetworkAccessManager>
#include <QRegularExpression>
#include <QGuiApplication>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QMimeDatabase>
#include <QEventLoop>
#include <QMimeType>
#include <QHttpPart>

#include "commanager.h"
#include "global.h"

static const QRegularExpression re("href=\"([^\"]+\\.png)\">.*?(\\d{4}-\\d{2}-\\d{2}\\s\\d{2}:\\d{2})");

ComManager::ComManager(QObject *parent)
    : QObject{parent}
{
    m_coversToUploadFile.setFileName(Global::PICPATH_ABS + "covers_to_upload.txt");
}

ComManager::~ComManager()
{
    if(m_coversToUploadFile.isOpen())
        m_coversToUploadFile.close();
}

void ComManager::downloadCovers(const QString& subfolder)
{
    // cannot use setProperty directly because thread separation
    QMetaObject::invokeMethod(m_progressDialog, "show");

    QDir picDir(Global::PICPATH_ABS);
    if(!picDir.exists()) picDir.mkpath(".");
    picDir.setFilter(QDir::Files | QDir::NoSymLinks);
    picDir.setNameFilters(QStringList() << "*.png");

    QDir toDir(Global::PICPATH_ABS + '/' + subfolder);
    if(!toDir.exists()) toDir.mkpath(".");
    toDir.setFilter(QDir::Files | QDir::NoSymLinks);
    toDir.setNameFilters(QStringList() << "*.png");

    // Before downloading, we check if a previsous version of the app already has cover in pic folder
    QStringList fileList = picDir.entryList();
    foreach (const QString &fileName, fileList) {
        QString sourceFilePath = picDir.absoluteFilePath(fileName);
        QString destinationFilePath = toDir.absoluteFilePath(fileName);
        QFile::rename(sourceFilePath, destinationFilePath);
    }

    int count = 0;

    QString remotePicSubfolder = Global::REMOTE_PIC_PATH + subfolder;
    QNetworkRequest request(remotePicSubfolder);
    QNetworkAccessManager manager;
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

                    QDateTime localModifiedDate(remoteCreationDate);

                    QString localPath = toDir.absolutePath() + "/" + remoteFileName;

                    if(QFile::exists(localPath)) {
                        QFileInfo localFileInfo(localPath);
                        localModifiedDate = localFileInfo.lastModified();
                    }

                    if(!QFile::exists(localPath) || (remoteCreationDate > localModifiedDate)) {
                        downloadFile(remotePicSubfolder + '/' + remoteFileName, localPath);
                        QMetaObject::invokeMethod(m_progressDialog, "setValue", Q_ARG(QVariant, ++count));
                    } else {
                        QMetaObject::invokeMethod(m_progressDialog, "setMaxValue", Q_ARG(QVariant, --remote_count));
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

void ComManager::uploadCovers()
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
        if(!s.isEmpty() && uploadFile(Global::PICPATH_ABS + s, Global::REMOTE_UPLOAD_PIC_SCRIPT)) {

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

bool ComManager::uploadFile(const QString& fileName, const QString& scriptPath)
{
    QFile file(fileName);
    if (!file.open(QIODevice::ReadOnly)) {
        qDebug() << "Impossible d'ouvrir le fichier";
        return false;
    }

    QMetaObject::invokeMethod(m_progressDialog, "show");

    QUrl url(scriptPath);
    QNetworkRequest request(url);

    QMimeDatabase mimeDatabase;
    QMimeType mimeType(mimeDatabase.mimeTypeForFile(QFileInfo(file)));

    QString fileBuild = fileName;

    if(fileName.contains('/')) {
        QString subfolder = fileName.section('/', -2, -2); // Obtient le nom du sous-dossier
        QString subFile = fileName.section('/', -1); // Obtient le nom de fichier avec l'extension

        fileBuild = subfolder + ":" + subFile;
    }

    QHttpPart filePart;
    filePart.setHeader(QNetworkRequest::ContentTypeHeader, mimeType.name());
    filePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"file\"; filename=\"" + fileBuild + "\""));
    filePart.setHeader(QNetworkRequest::ContentLengthHeader, file.size());
    filePart.setBodyDevice(&file);

    QHttpMultiPart multiPart(QHttpMultiPart::FormDataType);
    multiPart.append(filePart);

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

void ComManager::downloadDB()
{
    downloadFile(Global::REMOTE_DB_PATH + Global::DBNAME, Global::DB_PATH_ABS_NAME);
}

void ComManager::downloadFile(const QString& remotePath, const QString& localPath)
{
    QUrl url(remotePath);
    QNetworkRequest request(url);
    QNetworkAccessManager manager;
    QNetworkReply *reply = manager.get(request);

    QEventLoop loop;

    QObject::connect(reply, &QNetworkReply::finished, [&]() {
        if (reply->error() != QNetworkReply::NoError) {
            qDebug() << "Error:" << reply->errorString();
        } else {
            QFile localFile(localPath);
            if (localFile.open(QIODevice::WriteOnly)) {
                localFile.setPermissions(QFile::WriteOwner | QFile::ReadOwner);
                localFile.write(reply->readAll());
                localFile.close();
            }
        }
        reply->deleteLater();
        loop.quit();
    });

    loop.exec();
}

void ComManager::uploadDB()
{
    QMetaObject::invokeMethod(m_progressDialog, "show");

    uploadFile(Global::DB_PATH_ABS_NAME, Global::REMOTE_UPLOAD_DB_SCRIPT);

    QMetaObject::invokeMethod(m_progressDialog, "hide");
}

void ComManager::handleBackCover(const QString &tag)
{
    m_coversToUploadFile.open(QIODevice::ReadWrite | QIODevice::Text | QIODevice::Append);
    appendToList(tag + "_back.png");
    m_coversToUploadFile.close();
}

void ComManager::handleFrontCover(const QString &tag)
{
    m_coversToUploadFile.open(QIODevice::ReadWrite | QIODevice::Text | QIODevice::Append);
    appendToList(tag + "_front.png");
    m_coversToUploadFile.close();
}

void ComManager::setProgressDialog(QObject *dialog)
{
    m_progressDialog = dialog;
}

void ComManager::appendToList(const QString &fileName)
{
    QTextStream ts(&m_coversToUploadFile);
    ts.seek(0);

    QString all(ts.readAll());
    QStringList sl(all.split('\n'));
    if(!sl.contains(fileName)) {
        ts << fileName << '\n';
    }
}

