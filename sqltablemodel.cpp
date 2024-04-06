#include "sqltablemodel.h"
#include "filemanager.h"
#include "gamedata.h"

#include <QSqlDriver>
#include <QSqlRecord>
#include <QSqlField>

#include <QRegularExpression>
#include <QRegularExpressionMatch>

#include <QDebug>

SqlTableModel::SqlTableModel(QObject* parent, const QSqlDatabase &db)
    : QSqlTableModel(parent, db)
{
    setEditStrategy(QSqlTableModel::OnFieldChange);
    setTable("games");

    auto rec = record();
    for(int i = 0; i < rec.count(); i++) {
        m_roles.insert(Qt::UserRole + i + 1, rec.fieldName(i).toUtf8());
    }
    m_roles.insert(Qt::UserRole + rec.count() + 1, "subgame"); // extra role

    select();
}

SqlTableModel::~SqlTableModel()
{
}

QHash<int, QByteArray> SqlTableModel::roleNames() const
{
    return m_roles;
}

bool SqlTableModel::select()
{
    auto ret = QSqlTableModel::select();

    auto driver = database().driver();
    if(!driver->hasFeature(QSqlDriver::QuerySize)) {
        while(canFetchMore()) {
            fetchMore();
        }
    }

    return ret;
}

QStringList SqlTableModel::roleNamesList() const
{
    QStringList names;
    for(int i=0; i<record().count(); i++) {
        names << record().fieldName(i);
    }
    return names;
}

void SqlTableModel::updateData(const QModelIndex &index, const QVariantList& data)
{
    QMap<int, QVariant> rolesData;
    for(int i = 0; i < data.count(); i++) {
        rolesData.insert(Qt::UserRole + i + 1, data[i]);
    }

    setItemData(index, rolesData);

    submitAll();
}

QVariant SqlTableModel::data(const QModelIndex &index, int role) const
{
    if (index.isValid()) {
        if(role == Qt::UserRole + 9) {
            return m_subgamesVector[index.row()];
        }
        if (role >= Qt::UserRole) {
            int columnIdx = role - Qt::UserRole - 1;
            QModelIndex modelIndex = this->index(index.row(), columnIdx);
            return QSqlTableModel::data(modelIndex, Qt::DisplayRole);
        }
    }

    return QSqlTableModel::data(index, role);
}

bool SqlTableModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (index.isValid()) {
        if(role == Qt::UserRole + 9) {
            m_subgamesVector[index.row()] = value.toInt();
            return true;
        }
        if (role >= Qt::UserRole) {
            int columnIdx = role - Qt::UserRole - 1;
            QModelIndex modelIndex = this->index(index.row(), columnIdx);
            return QSqlTableModel::setData(modelIndex, value, Qt::EditRole);
        }
    }

    return QSqlTableModel::setData(index, value, role);
}

void SqlTableModel::saveDBToFile(FileManager* fileManager)
{
    if(!fileManager) {
        return;
    }
    for(int r = 0; r < rowCount(); r++) {
        QVariantList list;
        for(int c = 0; c < columnCount(); c++) {
            list.append(data(index(r, c), 0));
        }
        auto game = GameDataMaker::get()->createComplete(list);
        fileManager->addEntry(game);
    }
}

void SqlTableModel::resetOwnedData(int owned)
{
    QSqlQuery query(database());
    query.prepare("UPDATE games SET owned = :owned");
    query.bindValue(":owned", owned);

    query.exec();
    select();
}

QStringList SqlTableModel::saveOwnedData()
{
    QStringList tagList;

    QSqlQuery query(database());
    query.exec("SELECT tag FROM games WHERE owned = 1");

    while (query.next()) {
        tagList << query.value(0).toString();
    }

    return tagList;
}

void SqlTableModel::restoreOwnedData(QStringList &tagList)
{
    for (int row = 0; row < rowCount(); ++row) {
        auto tag = data(index(row, 0), Qt::UserRole + 1).toString(); // tag

        if(tagList.isEmpty()) break;

        auto it = tagList.begin();
        while(it != tagList.end()) {
            if(*it == tag) {
                setData(index(row, 0), 1, Qt::UserRole + 8); // owned
                tagList.erase(it); break;
            } else {
                ++it;
            }
        }
    }
    submitAll();
}
