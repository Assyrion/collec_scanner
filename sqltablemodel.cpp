#include "sqltablemodel.h"
#include "filemanager.h"
#include "gamedata.h"

#include <QSqlDriver>
#include <QSqlRecord>
#include <QSqlField>

#include <QDebug>

const QString platinum_code_marker = "/P";
const QString essentials_code_marker = "/E";

SqlTableModel::SqlTableModel(int orderBy, int sortOrder, const QString& titleFilter,
                             int ownedFilter, bool essentialsFilter, bool platinumFilter,
                             bool essentialsOnly, bool platinumOnly, QObject* parent)
    : QSqlQueryModel(parent),
    m_essentialsFilter(essentialsFilter),
    m_essentialsOnly(essentialsOnly),
    m_platinumFilter(platinumFilter),
    m_platinumOnly(platinumOnly),
    m_titleFilter(titleFilter),
    m_ownedFilter(ownedFilter)
{
    setQuery("SELECT * FROM games");

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
            return QSqlQueryModel::data(modelIndex, Qt::DisplayRole);
        }
    }

    return QSqlQueryModel::data(index, role);
}

bool SqlTableModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (index.isValid()) {
        if (role >= Qt::UserRole) {
            int columnIdx = role - Qt::UserRole - 1;
            QModelIndex modelIndex = this->index(index.row(), columnIdx);
            return QSqlQueryModel::setData(modelIndex, value, Qt::EditRole);
        }
    }

    return QSqlQueryModel::setData(index, value, role);
}

void SqlTableModel::remove(int row)
{
    removeRow(row);
//    select();
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

//    insertRecord(-1, rec);

    // not clean but no other solution found to make it quick
//    auto savedFilter = filter();
//    setFilter("tag = \'" + game->tag + "\'");
//    select();
//    setFilter(savedFilter);
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
//    auto savedFilter = filter();
//    setFilter("tag = \'" + game->tag + "\'");
//    select();
//    setFilter(savedFilter);
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
//    auto savedFilter = filter();
//    setFilter("");
//    int idx = getIndexFiltered(tag);
//    setFilter(savedFilter);

    return 0;
}

void SqlTableModel::filterEssentials(bool filter)
{
    m_essentialsFilter = filter;

    applyFilter();
}

void SqlTableModel::filterOnlyEssentials(bool filter)
{
    m_essentialsOnly = filter;

    applyFilter();
}

void SqlTableModel::filterPlatinum(bool filter)
{
    m_platinumFilter = filter;

    applyFilter();
}

void SqlTableModel::filterOnlyPlatinum(bool filter)
{
    m_platinumOnly = filter;

    applyFilter();
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

void SqlTableModel::removeFilter()
{
    m_titleFilter = "";
    m_ownedFilter = 2;

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
//    QSqlQuery query;
//    query.exec(QString("DELETE FROM %1").arg(tableName()));
//    select();
}

bool SqlTableModel::getEssentialsFilter() const
{
    return m_essentialsFilter;
}

bool SqlTableModel::getEssentialsOnly() const
{
    return m_essentialsOnly;
}

bool SqlTableModel::getPlatinumFilter() const
{
    return m_platinumFilter;
}

bool SqlTableModel::getPlatinumOnly() const
{
    return m_platinumOnly;
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

    if(m_ownedFilter < 2)
        cmd += QString(" AND owned = %1").arg(m_ownedFilter);

    if(!m_essentialsFilter)
        cmd += QString(" AND code NOT LIKE \'%%2%\'").arg(essentials_code_marker);

    if(!m_platinumFilter)
        cmd += QString(" AND code NOT LIKE \'%%2%\'").arg(platinum_code_marker);

    if(m_essentialsOnly) {
        cmd += QString(" AND code LIKE \'%%1%\'").arg(essentials_code_marker);

        if(m_platinumOnly)
            cmd += QString(" OR code LIKE \'%%1%\'").arg(platinum_code_marker);

    } else if(m_platinumOnly)
        cmd += QString(" AND code LIKE \'%%1%\'").arg(platinum_code_marker);

//    setFilter(cmd);
////    QString cmd = QString("title LIKE \'%%1%\'").arg(m_titleFilter);

//    m_filterModel->setFilterKeyColumn(1);
//    m_filterModel->setFilterFixedString(m_titleFilter);

////    if(m_ownedFilter < 2)
////        cmd += QString(" AND owned = %1").arg(m_ownedFilter);

//    if(!m_essentialsFilter) {
//        m_filterModel->setFilterKeyColumn(5);
//        m_filterModel->setFilterRegularExpression("^(?!.*\\/E).*");
//    }

//    if(!m_platinumFilter) {
//        m_filterModel->setFilterKeyColumn(5);
//        m_filterModel->setFilterRegularExpression("^(?!.*\\/P).*");
//    }

//    if(m_essentialsOnly && m_platinumOnly) {
//        m_filterModel->setFilterRegularExpression(".*\\/[EP].*");
//    } else if(m_essentialsOnly) {
//        m_filterModel->setFilterRegularExpression(".*\\/E.*");
//    } else if(m_platinumOnly)
//        m_filterModel->setFilterRegularExpression(".*\\/P.*");

////    setFilter(cmd);
}


