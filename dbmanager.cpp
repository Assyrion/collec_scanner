#include "dbmanager.h"
#include <QCoreApplication>
#include <QStandardPaths>
#include <QSqlRecord>
#include <QStringRef>
#include <QSqlQuery>
#include "gamedata.h"

#ifdef Q_OS_ANDROID
const QString DATAPATH = "/storage/E0FD-1813/CollecScanner";
#else
const QString DATAPATH = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation);
#endif

DBManager::DBManager(QObject *parent) : QObject(parent)
{
    m_db = QSqlDatabase::addDatabase("QSQLITE");
    m_db.setDatabaseName(DATAPATH + '/' + QCoreApplication::applicationName() + "/games.db");
    qDebug() << DATAPATH + '/' + QCoreApplication::applicationName();
    if (!m_db.open()) {
        qDebug() << "Error: connection with database fail";
    }
}

void DBManager::addEntry(GameData* game)
{
    QSqlQuery query;
    query.prepare("INSERT INTO games (tag, title, platform, publisher, developer) "
                  "VALUES (:tag, :title, :platform, :publisher, :developer)");
    query.bindValue(":tag",       game->tag);
    query.bindValue(":title",     game->title);
    query.bindValue(":platform",  game->platform);
    query.bindValue(":publisher", game->publisher);
    query.bindValue(":developer", game->developer);
    query.exec();
}

void DBManager::editEntry(GameData *game)
{
    QSqlQuery query;
    query.prepare("UPDATE games SET "
                  "title     = (:title), "
                  "platform  = (:platform), "
                  "publisher = (:publisher), "
                  "developer = (:developer) "
                  "WHERE tag = (:tag) ");
    query.bindValue(":tag",       game->tag);
    query.bindValue(":title",     game->title);
    query.bindValue(":platform",  game->platform);
    query.bindValue(":publisher", game->publisher);
    query.bindValue(":developer", game->developer);
    query.exec();
}

GameData* DBManager::getEntry(QString tag)
{
    QSqlQuery query;
    query.prepare("SELECT title, "
                  "platform, "
                  "publisher, "
                  "developer, "
                  "release_date, "
                  "pic_front, "
                  "pic_back "
                  "FROM games WHERE tag = (:tag)");
    query.bindValue(":tag", tag);
    if (query.exec()) {
        if (query.next()) {
            return new GameData {tag,
                        query.value(0).toString(),
                        query.value(1).toString(),
                        query.value(2).toString(),
                        query.value(3).toString(),
                        query.value(4).toDate(),
                        QUrl(toGlobalPath(query.value(5).toString())),
                        QUrl(toGlobalPath(query.value(6).toString()))};
        }
    }
    return nullptr;
}

QString DBManager::toGlobalPath(QString path)
{
    QString db_path = m_db.databaseName().remove("/games.db");
    if(!path.isEmpty()) {
        return db_path + '/' + path;
    }
    return "";
}

