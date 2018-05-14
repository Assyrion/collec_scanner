#include <QStandardPaths>
#include <QFileInfo>

#include "filemanager.h"
#include "gamedata.h"

FileManager::FileManager(QObject *parent) : QObject(parent)
{
    m_jvFile.setFileName(QStandardPaths::writableLocation(QStandardPaths::DownloadLocation)
                         + "/game_list.csv");
    m_jvFile.open(QIODevice::ReadWrite | QIODevice::Truncate | QIODevice::Text);
}

FileManager::~FileManager()
{
    m_jvFile.close();
}

void FileManager::addEntry(GameData* game)
{
    QTextStream ts(&m_jvFile);
    ts.setCodec("UTF-8");
    ts << *game << '\n';
}

QString FileManager::getEntry(QString id)
{
    QTextStream ts(&m_jvFile);
    ts.seek(0);
    QString line;
    QStringList data;
    while(!ts.atEnd()) {
        line = ts.readLine();
        data = line.split(';');
        if(data.size() > 1 && data[0] == id) {
            return data[1];
        }
    }
    return "";
}

bool FileManager::checkEntry(QString id)
{
    QTextStream ts(&m_jvFile);
    ts.seek(0);
    QString line;
    QStringList data;
    while(!ts.atEnd()) {
        line = ts.readLine();
        data = line.split(';');
        if(data.size() > 0 && data[0] == id) {
            return true;
        }
    }
    return false;
}
