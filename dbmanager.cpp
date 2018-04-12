#include "dbmanager.h"
#include <QCoreApplication>
#include <QStandardPaths>
#include <QSqlRecord>
#include <QSqlQuery>

#include "sqltablemodel.h"
#include "gamedata.h"
#include "global.h"

DBManager::DBManager(QObject *parent)
    : QObject(parent)
{}

void DBManager::addEntry(GameData* game)
{
    QSqlQuery query;
    query.prepare("INSERT INTO games (tag, title, platform, publisher, "
                  "developer, release_date) "
                  "VALUES ("
                  ":tag, "
                  ":title, "
                  ":platform, "
                  ":publisher, "
                  ":developer, "
                  ":release_date)");
    query.bindValue(":tag",          game->tag);
    query.bindValue(":title",        game->title);
    query.bindValue(":platform",     game->platform);
    query.bindValue(":publisher",    game->publisher);
    query.bindValue(":developer",    game->developer);
    query.bindValue(":release_date", game->releaseDate);
    query.exec();
}

void DBManager::writeEntry(GameData *game)
{
    QSqlQuery query;
    query.prepare("UPDATE games SET "
                  "title        = (:title), "
                  "platform     = (:platform), "
                  "publisher    = (:publisher), "
                  "developer    = (:developer), "
                  "release_date = (:release_date) "
                  "WHERE tag    = (:tag)");
    query.bindValue(":tag",          game->tag);
    query.bindValue(":title",        game->title);
    query.bindValue(":platform",     game->platform);
    query.bindValue(":publisher",    game->publisher);
    query.bindValue(":developer",    game->developer);
    query.bindValue(":release_date", game->releaseDate);
    query.exec();

    if(query.numRowsAffected() == 0) { // nothing to update
        addEntry(game); // add new game
    }
}

GameData* DBManager::getEntry(QString tag)
{
    m_model.setFilter(QString("tag = %1").arg(tag));
    QSqlQuery q = m_model.query();
    qDebug() << m_model.query().lastQuery() << m_model.record().value("title").toString();
    QSqlQuery query;
    query.prepare("SELECT title, "
                  "platform, "
                  "publisher, "
                  "developer, "
                  "release_date "
                  "FROM games WHERE tag = (:tag)");
    query.bindValue(":tag", tag);
    if (query.exec()) {
        if (query.next()) {
            auto game = { tag,
                        query.value(0).toString(),
                        query.value(1).toString(),
                        query.value(2).toString(),
                        query.value(3).toString(),
                        query.value(4).toString()};
            return GameDataMaker::get()->createComplete(game);
        }
    }
    return nullptr;
}
