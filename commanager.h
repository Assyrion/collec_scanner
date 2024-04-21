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

    void downloadCovers();
    Q_INVOKABLE void uploadCovers();

    bool checkNewDB() const;
    void downloadDB();
    Q_INVOKABLE void uploadDB();

    Q_INVOKABLE void handleFrontCover(const QString &tag);
    Q_INVOKABLE void handleBackCover(const QString &tag);
    Q_INVOKABLE QVariant getPriceFromEbay(const QString &tag);

    void setProgressDialog(QObject* dialog);

private:
    QFile m_coversToUploadFile;
    QObject* m_progressDialog{nullptr};

    void appendToList(const QString& fileName);
    bool checkNewFile(const QString& remotePath, const QString& localPath) const;
    void downloadFile(const QString& remotePath, const QString& localPath);
    bool uploadFile(const QString &fileName, const QString &scriptPath);
};

#endif // COMMANAGER_H
