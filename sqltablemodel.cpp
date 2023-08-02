#include "sqltablemodel.h"
#include "filemanager.h"
#include "gamedata.h"

#include <QSqlDriver>
#include <QSqlRecord>
#include <QSqlField>

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

    select();

    auto driver = database().driver();
    if(!driver->hasFeature(QSqlDriver::QuerySize)) {
        while(canFetchMore()) {
            fetchMore();
        }
    }
}

SqlTableModel::~SqlTableModel()
{}

QHash<int, QByteArray> SqlTableModel::roleNames() const
{
    return m_roles;
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

QHash<QString, int> SqlTableModel::saveOwnedData()
{
    QHash<QString, int> ownedHash;

    for (int row = 0; row < rowCount(); ++row) {
        auto tag   = data(index(row, 0), Qt::UserRole + 1).toString(); // tag
        auto owned = data(index(row, 0), Qt::UserRole + 8).toInt(); // owned

        ownedHash.insert(tag, owned);
    }

    return ownedHash;
}

void SqlTableModel::restoreOwnedData(const QHash<QString, int>& ownedHash)
{
    QHash<QString, int>::const_iterator it;

    for (it = ownedHash.constBegin(); it != ownedHash.constEnd(); ++it) {
        QSqlQuery query(database());
        query.prepare("UPDATE games SET owned = :owned WHERE tag = :tag");
        query.bindValue(":owned", it.value());
        query.bindValue(":tag", it.key());

        query.exec();
    }
    select();
}
