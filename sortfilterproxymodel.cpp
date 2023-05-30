#include "sortfilterproxymodel.h"

const QString platinum_code_marker = "/P";
const QString essentials_code_marker = "/E";

SortFilterProxyModel::SortFilterProxyModel(int orderBy, int sortOrder, const QString &titleFilter, int ownedFilter, bool essentialsFilter, bool platinumFilter, bool essentialsOnly, bool platinumOnly, QObject *parent)
    : QSortFilterProxyModel(parent),
    m_essentialsFilter(essentialsFilter),
    m_essentialsOnly(essentialsOnly),
    m_platinumFilter(platinumFilter),
    m_platinumOnly(platinumOnly),
    m_titleFilter(titleFilter),
    m_ownedFilter(ownedFilter)
{
    setFilterKeyColumn(0);
    setFilterCaseSensitivity(Qt::CaseInsensitive);
    setSortCaseSensitivity(Qt::CaseInsensitive);

    sort(orderBy, Qt::SortOrder(sortOrder));
    invalidateFilter();
}

void SortFilterProxyModel::sort(int column, Qt::SortOrder order)
{
    m_orderBy = column;
    m_sortOrder = order;

    if(sourceModel())
        sourceModel()->sort(column, order);

    QSortFilterProxyModel::sort(column, order);
}

void SortFilterProxyModel::filterEssentials(bool filter)
{
    m_essentialsFilter = filter;

    invalidateFilter();
}

void SortFilterProxyModel::filterOnlyEssentials(bool filter)
{
    m_essentialsOnly = filter;

    invalidateFilter();
}

void SortFilterProxyModel::filterPlatinum(bool filter)
{
    m_platinumFilter = filter;

    invalidateFilter();
}

void SortFilterProxyModel::filterOnlyPlatinum(bool filter)
{
    m_platinumOnly = filter;

    invalidateFilter();
}

void SortFilterProxyModel::filterByTitle(const QString &title)
{
    m_titleFilter = title;

    invalidateFilter();
}

void SortFilterProxyModel::filterByOwned(bool owned, bool notOwned)
{
    m_ownedFilter = ((owned ? 0b10 : 0)
                     | (notOwned ? 0b01 : 0)) - 1;

    invalidateFilter();
}

int SortFilterProxyModel::getIndexFiltered(const QString& tag)
{
    auto list = match(index(0, 0), Qt::UserRole + 1, tag);
    if(!list.isEmpty()) {
        return list.first().row();
    }

    return -1;
}

int SortFilterProxyModel::getIndexNotFiltered(const QString &tag)
{
//    setFilterWildcard("*");
//    int idx = getIndexFiltered(tag);
//    invalidateFilter();

    auto list = sourceModel()->match(index(0, 0), Qt::UserRole + 1, tag);
    if(!list.isEmpty()) {
        return list.first().row();
    }

    return -1;
}

bool SortFilterProxyModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    QModelIndex titleIndex= sourceModel()->index(sourceRow, 1, sourceParent);
    QString title= sourceModel()->data(titleIndex).toString();
    bool titleCheck = title.contains(m_titleFilter);

    QModelIndex codeIndex= sourceModel()->index(sourceRow, 5, sourceParent);
    QString code = sourceModel()->data(codeIndex).toString();
    bool codeCheck = true;

    if(m_essentialsFilter) {
        if(m_essentialsOnly) {
            codeCheck &= code.endsWith(essentials_code_marker);
        }
    } else {
        codeCheck &= !code.endsWith(essentials_code_marker);
    }
    if(m_platinumFilter) {
        if(m_platinumOnly) {
            codeCheck &= code.endsWith(platinum_code_marker);
        }
    } else {
        codeCheck &= !code.endsWith(platinum_code_marker);
    }

    QModelIndex ownedIndex= sourceModel()->index(sourceRow, 7, sourceParent);
    int owned = sourceModel()->data(ownedIndex).toInt();
    bool ownedCheck = (m_ownedFilter == owned) || (m_ownedFilter >= 2);

    return titleCheck && codeCheck && ownedCheck;
}

bool SortFilterProxyModel::getEssentialsFilter() const
{
    return m_essentialsFilter;
}

bool SortFilterProxyModel::getEssentialsOnly() const
{
    return m_essentialsOnly;
}

bool SortFilterProxyModel::getPlatinumFilter() const
{
    return m_platinumFilter;
}

bool SortFilterProxyModel::getPlatinumOnly() const
{
    return m_platinumOnly;
}

QString SortFilterProxyModel::getTitleFilter() const
{
    return m_titleFilter;
}

int SortFilterProxyModel::getOwnedFilter() const
{
    return m_ownedFilter;
}

int SortFilterProxyModel::getSortOrder() const
{
    return m_sortOrder;
}

int SortFilterProxyModel::getOrderBy() const
{
    return m_orderBy;
}

void SortFilterProxyModel::setSourceModel(QAbstractItemModel *sourceModel)
{
    QSortFilterProxyModel::setSourceModel(sourceModel);

    sourceModel->sort(m_orderBy, Qt::SortOrder(m_sortOrder));
}


//QVariant SortFilterProxyModel::headerData(int section, Qt::Orientation orientation, int role) const
//{
//    // FIXME: Implement me!
//}

//bool SortFilterProxyModel::setHeaderData(int section, Qt::Orientation orientation, const QVariant &value, int role)
//{
//    if (value != headerData(section, orientation, role)) {
//        // FIXME: Implement me!
//        emit headerDataChanged(orientation, section, section);
//        return true;
//    }
//    return false;
//}

//QModelIndex SortFilterProxyModel::index(int row, int column, const QModelIndex &parent) const
//{
//    // FIXME: Implement me!
//}

//QModelIndex SortFilterProxyModel::parent(const QModelIndex &index) const
//{
//    // FIXME: Implement me!
//}

//int SortFilterProxyModel::rowCount(const QModelIndex &parent) const
//{
//    if (!parent.isValid())
//        return 0;

//    // FIXME: Implement me!
//}

//int SortFilterProxyModel::columnCount(const QModelIndex &parent) const
//{
//    if (!parent.isValid())
//        return 0;

//    // FIXME: Implement me!
//}

//bool SortFilterProxyModel::hasChildren(const QModelIndex &parent) const
//{
//    // FIXME: Implement me!
//}

//bool SortFilterProxyModel::canFetchMore(const QModelIndex &parent) const
//{
//    // FIXME: Implement me!
//    return false;
//}

//void SortFilterProxyModel::fetchMore(const QModelIndex &parent)
//{
//    // FIXME: Implement me!
//}

//QVariant SortFilterProxyModel::data(const QModelIndex &index, int role) const
//{
//    if (!index.isValid())
//        return QVariant();

//    // FIXME: Implement me!
//    return QVariant();
//}

//bool SortFilterProxyModel::setData(const QModelIndex &index, const QVariant &value, int role)
//{
//    if (data(index, role) != value) {
//        // FIXME: Implement me!
//        emit dataChanged(index, index, {role});
//        return true;
//    }
//    return false;
//}

//Qt::ItemFlags SortFilterProxyModel::flags(const QModelIndex &index) const
//{
//    if (!index.isValid())
//        return Qt::NoItemFlags;

//    return QAbstractItemModel::flags(index) | Qt::ItemIsEditable; // FIXME: Implement me!
//}

//bool SortFilterProxyModel::insertRows(int row, int count, const QModelIndex &parent)
//{
//    beginInsertRows(parent, row, row + count - 1);
//    // FIXME: Implement me!
//    endInsertRows();
//    return true;
//}

//bool SortFilterProxyModel::insertColumns(int column, int count, const QModelIndex &parent)
//{
//    beginInsertColumns(parent, column, column + count - 1);
//    // FIXME: Implement me!
//    endInsertColumns();
//    return true;
//}

//bool SortFilterProxyModel::removeRows(int row, int count, const QModelIndex &parent)
//{
//    beginRemoveRows(parent, row, row + count - 1);
//    // FIXME: Implement me!
//    endRemoveRows();
//    return true;
//}

//bool SortFilterProxyModel::removeColumns(int column, int count, const QModelIndex &parent)
//{
//    beginRemoveColumns(parent, column, column + count - 1);
//    // FIXME: Implement me!
//    endRemoveColumns();
//    return true;
//}
