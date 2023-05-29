#include "sortfilterproxymodel.h"

SortFilterProxyModel::SortFilterProxyModel(QObject *parent)
    : QSortFilterProxyModel(parent)
{
    setFilterCaseSensitivity(Qt::CaseInsensitive);
    setSortCaseSensitivity(Qt::CaseInsensitive);
}

void SortFilterProxyModel::setOrderBy(int column, int order)
{
    qDebug() << column << order;
    if (column >= 0) {
        sort(column, Qt::SortOrder(order));
    }
}


void SortFilterProxyModel::filterEssentials(bool filter)
{
    setFilterKeyColumn(5);

    if(!filter)
        setFilterRegularExpression("^(?!.*\\/E).*");
    else
        setFilterRegularExpression("");

//    m_essentialsFilter = filter;

//    applyFilter();
}

void SortFilterProxyModel::filterOnlyEssentials(bool filter)
{
//    m_essentialsOnly = filter;

//    applyFilter();
}

void SortFilterProxyModel::filterPlatinum(bool filter)
{
    setFilterKeyColumn(5);

    if(!filter)
        setFilterRegularExpression("^(?!.*\\/P).*");
    else
        setFilterRegularExpression("");
//    m_platinumFilter = filter;

//    applyFilter();
}

void SortFilterProxyModel::filterOnlyPlatinum(bool filter)
{
    setFilterKeyColumn(5);

//    m_platinumOnly = filter;

//    applyFilter();
}

void SortFilterProxyModel::filterByTitle(const QString &title)
{
    setFilterKeyColumn(1);

    setFilterFixedString(/*m_titleFilter*/title);
//    m_titleFilter = title;

//    applyFilter();
}

void SortFilterProxyModel::filterByOwned(bool owned, bool notOwned)
{
    setFilterKeyColumn(7);

    /*m_ownedFilter*/int i = ((owned ? 0b10 : 0)
                     | (notOwned ? 0b01 : 0)) - 1;

    if(i < 2)
        setFilterRegularExpression(QString::number(i));
    else
        setFilterRegularExpression("");

//    applyFilter();
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
