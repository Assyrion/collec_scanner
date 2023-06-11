#include "databasemanager.h"
#include "global.h"
#include "qqml.h"
#include "qsqlerror.h"

DatabaseManager::DatabaseManager(QObject *parent)
    : QObject{parent}
{
    qmlRegisterType<SqlTableModel>("SqlTableModel", 1, 0, "SqlTableModel");
}

int DatabaseManager::loadDB(const QString &platform)
{
    Global::setDBName(QString("games_%1_complete.db").arg(platform));

    if (!m_modelHash.contains(platform)) {

        auto db = QSqlDatabase::addDatabase("QSQLITE", platform);
        db.setDatabaseName(Global::DB_PATH_ABS_NAME);

        // checking if needed to download DB
        if(!QFile::exists(Global::DB_PATH_ABS_NAME)) {
            emit unknownDatabase();
        }

        if (!db.open()) {
            qDebug() << "Error: connection with database fail" << db.lastError();
            return -1;
        } else if(!db.tables().contains("games")) { // wrong database
            qDebug() << "Error: database corrupted";
            db.close();
            QFile::remove(Global::DB_PATH_ABS_NAME);
            return -1;
        }
        m_modelHash.insert(platform, new SqlTableModel(nullptr, db));
    }

    m_currentSQLModel = m_modelHash.value(platform);
    emit currentSQLModelChanged();

    return 0;
}

SqlTableModel *DatabaseManager::currentSQLModel() const
{
    return m_currentSQLModel;
}
