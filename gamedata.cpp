#include "gamedata.h"
#include <QDebug>

GameDataMaker* GameDataMaker::instance = nullptr;
QMutex GameDataMaker::mutex;

GameData* GameDataMaker::createNew(const QString &tag)
{
    return new GameData(tag);
}

GameData *GameDataMaker::createComplete(const std::initializer_list<QString> &il)
{
    return new GameData(il);
}

GameDataMaker* GameDataMaker::get()
{
    QMutexLocker m(&mutex); // for thread-safety

    if(!instance) {
        return new GameDataMaker;
    }
    return instance;
}

GameData::GameData(QObject *parent)
    : QObject(parent)
{}

GameData::GameData(const std::initializer_list<QString>& il)
    : GameData(*il.begin(),    *(il.begin()+1), *(il.begin()+2),
              *(il.begin()+3), *(il.begin()+4)) // ugly
{}

GameData::GameData(QString tag)
    : GameData(tag, "undefined", "ps3")
{}

GameData::GameData(QString tag, QString title,  QString platform,
                   QString publisher, QString developer,
                   QString release_date)
    : tag(tag),
      title(title),
      platform(platform),
      publisher(publisher),
      developer(developer),
      releaseDate(release_date)
{}

GameData::~GameData()
{}
