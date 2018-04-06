#include "filemanager.h"
#include <QStandardPaths>
#include <QTextStream>
#include <QFileInfo>
#include <QDebug>

FileManager::FileManager(QObject *parent) : QObject(parent)
{
    m_jvFile.setFileName(QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation) + "/jvList.csv");
    m_jvFile.open(QIODevice::ReadWrite | QIODevice::Append);
}

FileManager::~FileManager()
{
    m_jvFile.close();
}

void FileManager::addEntry(QString id, QString title)
{
    QTextStream ts(&m_jvFile);
    ts.seek(0);
    ts << id << ';' << title << '\n';
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
        qDebug() << data;
        if(data.size() > 0 && data[0] == id) {
            return true;
        }
    }
    return false;
}
