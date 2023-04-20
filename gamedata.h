#ifndef GAMEDATA_H
#define GAMEDATA_H

#include <QTextStream>
#include <QQmlEngine>
#include <QMutex>
#include <QObject>
#include <QDate>
#include <QUrl>

class GameData;
class GameDataMaker : public QObject
{
    Q_OBJECT

public:
    Q_INVOKABLE GameData* createEmpty();
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

    Q_PROPERTY(QString tag          MEMBER tag)
    Q_PROPERTY(QString title        MEMBER title)
    Q_PROPERTY(QString full_title   MEMBER full_title)
    Q_PROPERTY(QString platform     MEMBER platform)
    Q_PROPERTY(QString publisher    MEMBER publisher)
    Q_PROPERTY(QString developer    MEMBER developer)
    Q_PROPERTY(QString code         MEMBER code)
    Q_PROPERTY(QString info         MEMBER info)

    friend class GameDataMaker;
    GameData();
    GameData(QString tag);
    GameData(const QStringList& il);
    GameData(QString tag, QString title, QString full_title = "",
             QString platform = "ps3",   QString publisher = "",
             QString developer = "",     QString code = "",
             QString info = "");
    ~GameData();

public:
    QString tag;
    QString info;
    QString title;
    QString full_title;
    QString platform;
    QString publisher;
    QString developer;
    QString code;

    friend QTextStream& operator<<(QTextStream& out, const GameData& game)
    {
        out << game.tag << ';' << game.title << ';' <<game.platform << ';'
            << game.publisher << ';' << game.developer << ';'
            << game.code << ';' <<game.info;
        return out;
    }
};


#endif // GAMEDATA_H
