#ifndef COMMANAGER_H
#define COMMANAGER_H


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

    void downloadDB();
    Q_INVOKABLE void uploadDB();

    Q_INVOKABLE void handleFrontCover(const QString &tag);
    Q_INVOKABLE void handleBackCover(const QString &tag);

    void setProgressDialog(QObject* dialog);

private:
    QFile m_coversToUploadFile;
    int m_coversToUploadCount{0};

    void appendToList(const QString& fileName);
    bool uploadToServer(const QString &fileName, const QString &scriptPath);

    QObject* m_progressDialog{nullptr};

signals:

};

#endif // COMMANAGER_H
