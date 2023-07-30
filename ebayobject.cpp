#include "ebayobject.h"

EbayObject::EbayObject(const QString& title, const QString& price,
                       const QString& condition, const QUrl& itemUrl,
                       QObject *parent)
    : QObject{parent},
    m_condition(condition),
    m_title(title),
    m_price(price),
    m_itemUrl(itemUrl)
{}

QString EbayObject::title() const
{
    return m_title;
}

QString EbayObject::price() const
{
    return m_price;
}

QString EbayObject::condition() const
{
    return m_condition;
}

QUrl EbayObject::itemUrl() const
{
    return m_itemUrl;
}
