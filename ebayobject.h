#ifndef EBAYOBJECT_H
#define EBAYOBJECT_H

#include "qurl.h"
#include <QObject>

class EbayObject : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString condition READ condition NOTIFY conditionChanged)
    Q_PROPERTY(QUrl itemUrl READ itemUrl NOTIFY itemUrlChanged)
    Q_PROPERTY(QString title READ title NOTIFY titleChanged)
    Q_PROPERTY(QString price READ price NOTIFY priceChanged)

public:
    explicit EbayObject(const QString& title, const QString& price,
                        const QString& condition, const QUrl& itemUrl,
                        QObject *parent = nullptr);

    QString condition() const;
    QUrl itemUrl() const;
    QString title() const;
    QString price() const;

private:
    QString m_condition;
    QString m_title;
    QString m_price;
    QUrl m_itemUrl;

signals:
    void conditionChanged();
    void itemUrlChanged();
    void titleChanged();
    void priceChanged();

};

#endif // EBAYOBJECT_H
