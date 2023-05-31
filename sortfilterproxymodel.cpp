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
    m_ownedFilter(ownedFilter),
    m_sortOrder(sortOrder),
    m_orderBy(orderBy)
{}

void SortFilterProxyModel::sort(int column, Qt::SortOrder order)
{
    m_orderBy = column;
    m_sortOrder = order;

    QSortFilterProxyModel::sort(column, order);
}

void SortFilterProxyModel::setSourceModel(QAbstractItemModel *sourceModel)
{
    QSortFilterProxyModel::setSourceModel(sourceModel);

    setFilterKeyColumn(0);
    setFilterCaseSensitivity(Qt::CaseInsensitive);
    setSortCaseSensitivity(Qt::CaseInsensitive);

    sort(m_orderBy, Qt::SortOrder(m_sortOrder));

    invalidateFilter();
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
