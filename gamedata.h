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

public:
    GameData(QString tag, QString title,  QString platform,
             QString publisher = "",      QString developer = "",
             QDate releaseDate = QDate(), QObject *parent = nullptr);

    GameData(QObject *parent = nullptr);
    ~GameData();

    QString tag;
    QString title;
    QString platform;
    QString publisher;
    QString developer;
    QDate   releaseDate;

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
};

#endif // GAMEDATA_H
