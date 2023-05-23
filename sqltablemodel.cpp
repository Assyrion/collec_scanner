#include "sqltablemodel.h"
#include "filemanager.h"
#include "gamedata.h"

#include <QSqlDriver>
#include <QSqlRecord>
#include <QSqlField>

#include <QDebug>

SqlTableModel::SqlTableModel(int orderBy, int sortOrder, const QString& titleFilter, int ownedFilter, QObject* parent)
    : QSqlTableModel(parent), m_titleFilter(titleFilter), m_ownedFilter(ownedFilter)
{
    setTable("games");
    setEditStrategy(OnFieldChange);
    this->setOrderBy(orderBy, sortOrder);

    auto rec = record();
    for(int i = 0; i < rec.count(); i++) {
        m_roles.insert(Qt::UserRole + i + 1, rec.fieldName(i).toUtf8());
    }

    applyFilter();
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

void SqlTableModel::remove(int row)
{
    beginRemoveRows(QModelIndex(), row, row);
    removeRow(row);
    endRemoveRows();
}

void SqlTableModel::insert(GameData* game)
{
    if(!game)
        return;

    QSqlRecord rec = record();
    rec.setValue("tag", game->tag);
    rec.setValue("title", game->title);
    rec.setValue("platform", game->platform);
    rec.setValue("publisher", game->publisher);
    rec.setValue("developer", game->developer);
    rec.setValue("code", game->code);
    rec.setValue("info", game->info);
    rec.setValue("owned", game->owned ? 1 : 0);

    insertRecord(-1, rec);

    // not clean but no other solution found to make it quick
    auto savedFilter = filter();
    setFilter("tag = \'" + game->tag + "\'");
    select();
    setFilter(savedFilter);
}

void SqlTableModel::update(int row, GameData* game)
{
    if(!game || row >= rowCount())
        return;

    setData(index(row, 0), game->tag);
    setData(index(row, 1), game->title);
    setData(index(row, 2), game->platform);
    setData(index(row, 3), game->publisher);
    setData(index(row, 4), game->developer);
    setData(index(row, 5), game->code);
    setData(index(row, 6), game->info);
    setData(index(row, 7), game->owned);

    // not clean but no other solution found to make it quick
    auto savedFilter = filter();
    setFilter("tag = \'" + game->tag + "\'");
    select();
    setFilter(savedFilter);
}

int SqlTableModel::getIndexFiltered(const QString& tag)
{
    auto list = match(index(0, 0), Qt::UserRole + 1, tag);
    if(!list.isEmpty()) {
        return list.first().row();
    }

    return -1;
}

int SqlTableModel::getIndexNotFiltered(const QString &tag)
{
    auto savedFilter = filter();
    setFilter("");
    int idx = getIndexFiltered(tag);
    setFilter(savedFilter);

    return idx;
}

void SqlTableModel::filterByTitle(const QString &title)
{
    m_titleFilter = title;

    applyFilter();
}

void SqlTableModel::filterByOwned(bool owned, bool notOwned)
{
    m_ownedFilter = ((owned ? 0b10 : 0)
                | (notOwned ? 0b01 : 0)) - 1;

    applyFilter();
}

void SqlTableModel::setOrderBy(int column, int order)
{
    m_orderBy = column;
    m_sortOrder = order;

    // Sort the model by the specified role and order
    if (column >= 0) {
        sort(column, Qt::SortOrder(order));
    }
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

void SqlTableModel::clearDB()
{
    QSqlQuery query;
    query.exec(QString("DELETE FROM %1").arg(tableName()));
    select();
}

QString SqlTableModel::getTitleFilter() const
{
    return m_titleFilter;
}

int SqlTableModel::getOwnedFilter() const
{
    return m_ownedFilter;
}

int SqlTableModel::getSortOrder() const
{
    return m_sortOrder;
}

int SqlTableModel::getOrderBy() const
{
    return m_orderBy;
}

void SqlTableModel::applyFilter()
{
    QString cmd = QString("title LIKE \'%%1%\'").arg(m_titleFilter);
    if(m_ownedFilter < 2) {
        cmd += QString(" AND owned = %1").arg(m_ownedFilter);
    }
    setFilter(cmd);
}
