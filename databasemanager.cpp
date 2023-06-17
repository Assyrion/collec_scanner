#include "databasemanager.h"
#include "global.h"
#include "qsqlerror.h"

DatabaseManager::DatabaseManager(QHash<QString, QVariantHash>& paramHash, QObject *parent)
    : QObject{parent}, m_paramHash(paramHash)
{}

DatabaseManager::~DatabaseManager()
{
    m_modelHash.clear();
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
        auto proxyModel = new SortFilterProxyModel(m_paramHash[platform]);
        proxyModel->setSourceModel(new SqlTableModel(nullptr, db));

        m_modelHash.insert(platform, proxyModel);
    }

    m_currentProxyModel = m_modelHash.value(platform);

    emit currentSqlModelChanged();
    emit currentProxyModelChanged();

    return 0;
}

SortFilterProxyModel* DatabaseManager::currentProxyModel() const
{
    return m_currentProxyModel;
}

SqlTableModel *DatabaseManager::currentSqlModel() const
{
    return static_cast<SqlTableModel*>(m_currentProxyModel->sourceModel());
}
