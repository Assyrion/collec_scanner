
#ifndef COVERMANAGER_H
#define COVERMANAGER_H


#include <QObject>
#include <QFile>

class CoverManager : public QObject
{
    Q_OBJECT
public:
    explicit CoverManager(QObject *parent = nullptr);
    ~CoverManager();

    Q_INVOKABLE void downloadCovers();
    Q_INVOKABLE void uploadCovers();

    Q_INVOKABLE void handleFrontCover(const QString &tag);
    Q_INVOKABLE void handleBackCover(const QString &tag);

    void setProgressDialog(QObject* dialog);

private:
    QFile m_coversToUploadFile;
    int m_coversToUploadCount{0};

    void appendToList(const QString& fileName);
    bool uploadToServer(const QString &fileName);

    QObject* m_progressDialog{nullptr};

signals:

};

#endif // COVERMANAGER_H
