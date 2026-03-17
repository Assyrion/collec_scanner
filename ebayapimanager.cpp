#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QJsonObject>
#include <QJsonArray>
#include <QEventLoop>
#include <QUrlQuery>

#include "ebayapimanager.h"
#include "ebayobject.h"
#include "global.h"

EbayAPIManager::EbayAPIManager(const QString &token, QObject *parent)
    : QObject{parent}, m_token(token)
{
    fetchKeysFromServer();
}

EbayAPIManager::~EbayAPIManager()
{}

QVariant EbayAPIManager::getCurrentSales(const QString &tag, bool retryOnAuthError)
{
    // 1. Configuration de l'URL et des paramètres de tri API
    QUrl url("https://api.ebay.com/buy/browse/v1/item_summary/search");
    QUrlQuery query;
    query.addQueryItem("q", tag);
    query.addQueryItem("limit", "10");
    query.addQueryItem("sort", "price");

    url.setQuery(query);

    QNetworkRequest request(url);
    request.setRawHeader("Authorization", "Bearer " + m_token.toUtf8());
    request.setRawHeader("X-EBAY-C-MARKETPLACE-ID", "EBAY_FR");
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    // Utilisation d'un manager local (ou idéalement m_networkManager membre de classe)
    QNetworkAccessManager manager;
    QNetworkReply *reply = manager.get(request);

    // Boucle d'attente synchrone
    QEventLoop loop;
    QObject::connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    loop.exec();

    // 2. Gestion du rafraîchissement de Token (Erreur 401)
    int httpCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    if (httpCode == 401 && retryOnAuthError) {
        qDebug() << "Token expiré, tentative de rafraîchissement...";
        reply->deleteLater();

        if (this->refreshEbayToken()) {
            // On relance la fonction avec le nouveau token
            return getCurrentSales(tag, false);
        }
    }

    QList<QObject*> itemList;

    // 3. Traitement des données (Déjà triées par eBay)
    if (reply->error() == QNetworkReply::NoError) {
        QJsonDocument jsonDoc = QJsonDocument::fromJson(reply->readAll());
        QJsonObject root = jsonDoc.object();
        QJsonArray itemsArray = root["itemSummaries"].toArray();

        for (const QJsonValue &itemValue : std::as_const(itemsArray)) {
            QJsonObject item = itemValue.toObject();
            QJsonObject priceObj = item["price"].toObject();

            // Création de l'objet pour QML/Interface
            itemList.append(new EbayObject(
                item["title"].toString(),
                priceObj["value"].toString() + " " + priceObj["currency"].toString(),
                item["condition"].toString(),
                QUrl(item["itemWebUrl"].toString())
                ));
        }
    } else {
        qDebug() << "Erreur eBay :" << reply->errorString() << reply->readAll();
    }

    reply->deleteLater();

    // On retourne la liste encapsulée dans un QVariant pour le QML ou les modèles
    return QVariant::fromValue(itemList);
}

QString EbayAPIManager::token() const
{
    return m_token;
}

void EbayAPIManager::fetchKeysFromServer()
{
    QNetworkAccessManager manager;
    QUrl url(Global::REMOTE_EBAYAPIKEYS_SCRIPT);
    QNetworkRequest request(url);

    QNetworkReply *reply = manager.get(request);

    QEventLoop loop;
    QObject::connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    loop.exec();

    if (reply->error() == QNetworkReply::NoError) {
        QJsonDocument doc = QJsonDocument::fromJson(reply->readAll());
        m_appId = doc.object().value("ebay_appid").toString();
        m_certId = doc.object().value("ebay_certid").toString();
    }

    reply->deleteLater();
}

bool EbayAPIManager::refreshEbayToken()
{
    QNetworkAccessManager manager;
    QUrl url("https://api.ebay.com/identity/v1/oauth2/token");
    QNetworkRequest request(url);

    // Identifiants eBay (AppID:CertID encodés en Base64)
    QString keys = m_appId + ':' + m_certId;
    request.setRawHeader("Authorization", "Basic " + keys.toUtf8().toBase64());
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");

    QUrlQuery params;
    params.addQueryItem("grant_type", "client_credentials");
    params.addQueryItem("scope", "https://api.ebay.com/oauth/api_scope");

    QNetworkReply *reply = manager.post(request, params.toString(QUrl::FullyEncoded).toUtf8());

    QEventLoop loop;
    QObject::connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    loop.exec();

    if (reply->error() == QNetworkReply::NoError) {
        QJsonDocument doc = QJsonDocument::fromJson(reply->readAll());
        m_token = doc.object().value("access_token").toString();
        reply->deleteLater();
        return true;
    }

    qDebug() << "Echec du rafraîchissement Token :" << reply->readAll();
    reply->deleteLater();
    return false;
}
