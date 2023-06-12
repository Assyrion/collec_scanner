#ifndef COMMANAGER_H
#define COMMANAGER_H

#include <QNetworkAccessManager>
#include <QObject>
#include <QFile>

class ComManager : public QObject
{
    Q_OBJECT
public:
    explicit ComManager(QObject *parent = nullptr);
    ~ComManager();

    void downloadCovers(const QString &subfolder);
    Q_INVOKABLE void uploadCovers();

    void downloadDB();
    Q_INVOKABLE void uploadDB();

    Q_INVOKABLE void handleFrontCover(const QString &tag);
    Q_INVOKABLE void handleBackCover(const QString &tag);

    void setProgressDialog(QObject* dialog);

private:
    QFile m_coversToUploadFile;
    QObject* m_progressDialog{nullptr};

    void appendToList(const QString& fileName);
    void downloadFile(const QString& remotePath, const QString& localPath);
    bool uploadFile(const QString &fileName, const QString &scriptPath);

signals:

};

#endif // COMMANAGER_H
