#ifndef GAMEDATA_H
#define GAMEDATA_H

#include <QQmlEngine>
#include <QObject>
#include <QDate>
#include <QUrl>

class GameData : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString tag         MEMBER tag         NOTIFY tagChanged)
    Q_PROPERTY(QString title       MEMBER title       NOTIFY titleChanged)
    Q_PROPERTY(QString platform    MEMBER platform    NOTIFY platformChanged)
    Q_PROPERTY(QString publisher   MEMBER publisher   NOTIFY publisherChanged)
    Q_PROPERTY(QString developer   MEMBER developer   NOTIFY developerChanged)
    Q_PROPERTY(QDate   releaseDate MEMBER releaseDate NOTIFY releaseDateChanged)
    Q_PROPERTY(QUrl    picFront    MEMBER picFront    NOTIFY picFrontChanged)
    Q_PROPERTY(QUrl    picBack     MEMBER picBack     NOTIFY picBackChanged)


public:
    GameData(QString tag, QString title,  QString platform,
             QString publisher = "",      QString developer = "",
             QDate releaseDate = QDate(), QUrl picFront = QUrl(),
             QUrl picBack = QUrl(), QObject *parent = nullptr);

    GameData(QObject *parent = nullptr);
    ~GameData();

    QString tag;
    QString title;
    QString platform;
    QString publisher;
    QString developer;
    QDate   releaseDate;
    QUrl    picFront;
    QUrl    picBack;

    static void registerQMLTypes() {
        qmlRegisterType<GameData>("GameData", 1, 0, "GameData");
    }

    Q_INVOKABLE void clear();

signals:
    void tagChanged();
    void titleChanged();
    void platformChanged();
    void publisherChanged();
    void developerChanged();
    void releaseDateChanged();
    void picFrontChanged();
    void picBackChanged();
};

#endif // GAMEDATA_H
