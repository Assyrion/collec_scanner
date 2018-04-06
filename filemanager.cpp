#include "filemanager.h"
#include <QStandardPaths>
#include <QTextStream>
#include <QFileInfo>
#include <QDebug>

FileManager::FileManager(QObject *parent) : QObject(parent)
{
    m_jvFile.setFileName(QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation) + "/jvList.csv");
    qDebug() << QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation);
    qDebug() << m_jvFile.open(QIODevice::ReadWrite | QIODevice::Append);
}

FileManager::~FileManager()
{
    m_jvFile.close();
}

void FileManager::addEntry(QString id, QString title)
{
    QTextStream ts(&m_jvFile);
    ts << id << ';' << title << '\n';
}

QString FileManager::getEntry(QString id)
{
    QTextStream ts(&m_jvFile);
    QString line;
    QStringList data;
    while(!ts.atEnd()) {
        line = ts.readLine();
        data = line.split(';');
        if(data.size() > 0 && data[0] == id) {
            return id;
        }
    }
    return "";
}

bool FileManager::checkEntry(QString id)
{
    QTextStream ts(&m_jvFile);
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
