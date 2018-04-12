#ifndef GAMEDATA_H
#define GAMEDATA_H

#include <QQmlEngine>
#include <QMutex>
#include <QObject>
#include <QDate>
#include <QUrl>

#include <QDebug>

class GameData;
class GameDataMaker : public QObject
{
    Q_OBJECT

public:
    Q_INVOKABLE GameData* createNew(const QString& tag);
    Q_INVOKABLE GameData* createComplete(const QStringList &il);
    static GameDataMaker* get();

    static void registerQMLTypes() {
        qmlRegisterUncreatableType<GameData>(   "GameData", 1, 0, "GameData", "Cannot create GameData");
        qmlRegisterSingletonType<GameDataMaker>("GameData", 1, 0, "GameDataMaker", [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
            Q_UNUSED(engine)
            Q_UNUSED(scriptEngine)
            return GameDataMaker::get();
        });
    }
private:
    static QMutex mutex;
    static GameDataMaker* instance;
};

class GameData : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString tag         MEMBER tag CONSTANT)
    Q_PROPERTY(QString title       MEMBER title)
    Q_PROPERTY(QString platform    MEMBER platform)
    Q_PROPERTY(QString publisher   MEMBER publisher)
    Q_PROPERTY(QString developer   MEMBER developer)
    Q_PROPERTY(QString releaseDate MEMBER releaseDate)

    friend class GameDataMaker;
    GameData(QString tag);
    GameData(QObject *parent = nullptr);
    GameData(const QStringList& il);
    GameData(QString tag, QString title,  QString platform,
             QString publisher = "", QString developer = "",
             QString release_date = "");
    ~GameData();

public:
    QString tag;
    QString title;
    QString platform;
    QString publisher;
    QString developer;
    QString releaseDate;

signals:
    void titleChanged();
    void platformChanged();
    void publisherChanged();
    void developerChanged();
    void releaseDateChanged();
};

#endif // GAMEDATA_H
