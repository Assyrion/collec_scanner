#include "gamedata.h"

GameDataMaker* GameDataMaker::instance = nullptr;
QMutex GameDataMaker::mutex;

GameData* GameDataMaker::createNew(const QString &tag)
{
    return new GameData(tag);
}

GameData* GameDataMaker::createEmpty()
{
    return new GameData;
}

GameData *GameDataMaker::createComplete(const QStringList &il)
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

GameData::GameData()
    : GameData("", "", "", "ps3")
{}

GameData::GameData(const QStringList &il)
    : GameData(*il.begin(),    *(il.begin()+1), *(il.begin()+2),
              *(il.begin()+3), *(il.begin()+4), *(il.begin()+5),
              *(il.begin()+6), *(il.begin()+7)) // ugly
{}

GameData::GameData(QString tag)
    : GameData(tag, "", "", "ps3")
{}

GameData::GameData(QString tag, QString title, QString full_title,
                   QString platform,  QString publisher, QString developer,
                   QString code, QString info)
    : tag(tag),
      title(title),
      full_title(full_title),
      platform(platform),
      publisher(publisher),
      developer(developer),
      code(code),
      info(info)
{}

GameData::~GameData()
{}
