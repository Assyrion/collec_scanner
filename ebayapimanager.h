#ifndef EBAYAPIMANAGER_H
#define EBAYAPIMANAGER_H

#include <QObject>
#include <QVariant>

class EbayAPIManager : public QObject
{
    Q_OBJECT
public:
    explicit EbayAPIManager(const QString &token, QObject *parent = nullptr);
    ~EbayAPIManager();

    Q_INVOKABLE QVariant getCurrentSales(const QString &tag, bool retryOnAuthError = true);

    QString token() const;

private:
    QString m_token;
    QString m_appId;
    QString m_certId;

    bool refreshEbayToken();
    void fetchKeysFromServer();

signals:
};

#endif // EBAYAPIMANAGER_H
