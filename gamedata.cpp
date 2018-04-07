#include "gamedata.h"
#include <QDebug>

GameData::GameData(QString tag, QString title,  QString platform,
                   QString publisher, QString developer,
                   QDate releaseDate, QUrl picFront,
                   QUrl picBack, QObject* parent)
    : QObject(parent),
      tag(tag),
      title(title),
      platform(platform),
      publisher(publisher),
      developer(developer),
      releaseDate(releaseDate),
      picFront(picFront),
      picBack(picBack)
{}

GameData::GameData(QObject *parent)
: QObject(parent)
{}

GameData::~GameData()
{}

void GameData::clear()
{
//    tag.clear();
//    title.clear();
//    platform.clear();
//    publisher.clear();
//    developer.clear();
//    releaseDate = QDate();
}
