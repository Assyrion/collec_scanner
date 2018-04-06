#include "dbmanager.h"
#include <QStandardPaths>
#include <QSqlRecord>
#include <QSqlQuery>

const QString DATAPATH = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation);

DBManager::DBManager(QObject *parent) : QObject(parent)
{
    m_db = QSqlDatabase::addDatabase("QSQLITE");
    m_db.setDatabaseName(DATAPATH + "/games.db");

    if (!m_db.open()) {
        qDebug() << "Error: connection with database fail";
    }
}

void DBManager::addEntry(QString barcode, QString title)
{
    QSqlQuery query;
    query.prepare("INSERT INTO games (barcode, title) VALUES (:barcode, :title)");
    query.bindValue(":barcode", barcode);
    query.bindValue(":title", title);
    query.exec();
}

QString DBManager::getEntry(QString barcode)
{
    QSqlQuery query;
    query.prepare("SELECT title FROM games WHERE barcode = (:barcode)");
    query.bindValue(":barcode", barcode);
    if (query.exec()) {
       if (query.next()) {
          return query.value(0).toString();
       }
    }
    return "";
}

