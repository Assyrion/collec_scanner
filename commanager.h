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

    bool checkNewDB();
    void downloadDB();
    Q_INVOKABLE void uploadDB();

    Q_INVOKABLE void handleFrontCover(const QString &tag);
    Q_INVOKABLE void handleBackCover(const QString &tag);
    Q_INVOKABLE QVariant getPriceFromEbay(const QString &tag);

private:
    QFile m_coversToUploadFile;

    void appendToList(const QString& fileName);
    bool checkNewFile(const QString& remotePath, const QString& localPath) const;
    void downloadFile(const QString& remotePath, const QString& localPath);
    bool uploadFile(const QString &fileName, const QString &scriptPath);

signals:
    void checkingNewDBStarted();
    void checkingNewDBFinished();
    void uploadingDBStarted();
    void uploadingDBFinished();
    void downloadingCoversStarted();
    void downloadingCoversFinished();
    void uploadingCoversStarted();
    void uploadingCoversFinished();

    void maxValueChanged(int val);
    void valueChanged(int val);
};

#endif // COMMANAGER_H
