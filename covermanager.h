
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

    Q_INVOKABLE bool uploadToServer(const QString &fileName);
    Q_INVOKABLE void downloadCovers();
    Q_INVOKABLE void uploadCovers();

    Q_INVOKABLE void uploadCover(const QString &fileName);

    void setProgressDialog(QObject* dialog);

private:
    QFile m_coversToUploadFile;
    void appendToList(const QString& fileName);

    QObject* m_progressDialog;

signals:

};

#endif // COVERMANAGER_H
