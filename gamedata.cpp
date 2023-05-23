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

GameData *GameDataMaker::createComplete(const QVariantList &il)
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

GameData::GameData(const QVariantList &il)
    : GameData(il.begin()->toString(),    (il.begin()+1)->toString(), (il.begin()+2)->toString(),
              (il.begin()+3)->toString(), (il.begin()+4)->toString(), (il.begin()+5)->toString(),
              (il.begin()+6)->toString(), (il.begin()+7)->toBool()) // ugly
{}

GameData::GameData(QString tag)
    : GameData(tag, "", "", "ps3")
{}

GameData::GameData(QString tag, QString title, QString platform,
                   QString publisher, QString developer,
                   QString code, QString info, bool owned)
    : tag(tag),
    info(info),
    title(title),
    platform(platform),
    publisher(publisher),
    developer(developer),
    code(code),
    owned(owned)
{}

GameData::~GameData()
{}
