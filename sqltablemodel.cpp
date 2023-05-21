#include "sqltablemodel.h"
#include "filemanager.h"
#include "gamedata.h"

#include <QSqlDriver>
#include <QSqlRecord>
#include <QSqlField>

#include <QDebug>

SqlTableModel::SqlTableModel(int orderBy, int sortOrder, const QString& filter, QObject* parent)
    : QSqlTableModel(parent)
{
    setTable("games");
    setEditStrategy(OnFieldChange);
    this->setOrderBy(orderBy, sortOrder);
    filterByTitle(filter);

    auto rec = record();
    for(int i = 0; i < rec.count(); i++) {
        m_roles.insert(Qt::UserRole + i + 1, rec.fieldName(i).toUtf8());
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

QVariant SqlTableModel::data(const QModelIndex &index, int role) const
{
    QVariant value;

    if (index.isValid()) {
        if (role < Qt::UserRole) {
            value = QSqlTableModel::data(index, role);
        } else {
            int columnIdx = role - Qt::UserRole - 1;
            QModelIndex modelIndex = this->index(index.row(), columnIdx);
            value = QSqlTableModel::data(modelIndex, Qt::DisplayRole);
        }
    }
    return value;
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

    insertRecord(-1, rec);
    qDebug() << getIndexFiltered(game->tag);

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
    m_filter = title;

    if(title.isEmpty()) {
        setFilter("");
        return;
    }

    setFilter("title LIKE \'%" + title + "%\'");
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
        QStringList list;
        for(int c = 0; c < columnCount(); c++) {
            list.append(data(index(r, c), 0).toString());
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

QString SqlTableModel::getFilter() const
{
    return m_filter;
}

int SqlTableModel::getSortOrder() const
{
    return m_sortOrder;
}

int SqlTableModel::getOrderBy() const
{
    return m_orderBy;
}
