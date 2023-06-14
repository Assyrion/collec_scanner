#include "sortfilterproxymodel.h"

const QString platinum_code_marker = "/P";
const QString essentials_code_marker = "/E";

SortFilterProxyModel::SortFilterProxyModel(QVariantHash &params, QObject *parent)
    : QSortFilterProxyModel(parent),
    m_essentialsFilter(params["essentialsFilter"]),
    m_essentialsOnly(params["essentialsOnly"]),
    m_platinumFilter(params["platinumFilter"]),
    m_platinumOnly(params["platinumOnly"]),
    m_titleFilter(params["titleFilter"]),
    m_ownedFilter(params["ownedFilter"]),
    m_sortOrder(params["sortOrder"]),
    m_orderBy(params["orderBy"])
{
    // check validity
    m_essentialsFilter = getEssentialsFilter();
    m_essentialsOnly = getEssentialsOnly();
    m_platinumFilter = getPlatinumFilter();
    m_platinumOnly = getPlatinumOnly();
    m_titleFilter = getTitleFilter();
    m_ownedFilter = getOwnedFilter();
    m_sortOrder = getSortOrder();
    m_orderBy = getOrderBy();
}

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

    sort(m_orderBy.toInt(), m_sortOrder.value<Qt::SortOrder>());

    invalidateFilter();
}

void SortFilterProxyModel::resetFilter()
{
    m_essentialsFilter = true;
    m_platinumFilter = true;
    m_essentialsOnly = false;
    m_platinumOnly = false;
    m_titleFilter = "";
    m_ownedFilter = 2;

    emit essentialsFilterChanged();
    emit essentialsOnlyChanged();
    emit platinumFilterChanged();
    emit platinumOnlyChanged();
    emit titleFilterChanged();
    emit ownedFilterChanged();

    invalidateFilter();
}

void SortFilterProxyModel::filterEssentials(bool filter)
{
    m_essentialsFilter = filter;
    emit essentialsFilterChanged();

    invalidateFilter();
}

void SortFilterProxyModel::filterOnlyEssentials(bool filter)
{
    m_essentialsOnly = filter;
    emit essentialsOnlyChanged();

    invalidateFilter();
}

void SortFilterProxyModel::filterPlatinum(bool filter)
{
    m_platinumFilter = filter;
    emit platinumFilterChanged();

    invalidateFilter();
}

void SortFilterProxyModel::filterOnlyPlatinum(bool filter)
{
    m_platinumOnly = filter;
    emit platinumOnlyChanged();

    invalidateFilter();
}

void SortFilterProxyModel::filterByTitle(const QString &title)
{
    m_titleFilter = title;
    emit titleFilterChanged();

    invalidateFilter();
}

void SortFilterProxyModel::filterByOwned(bool owned, bool notOwned)
{
    m_ownedFilter = ((owned ? 0b10 : 0)
                  | (notOwned ? 0b01 : 0)) - 1;
    emit ownedFilterChanged();

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
    auto list = sourceModel()->match(sourceModel()->index(0, 0), Qt::UserRole + 1, tag);
    if(!list.isEmpty()) {
        return list.first().row();
    }

    return -1;
}

bool SortFilterProxyModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    QModelIndex titleIndex= sourceModel()->index(sourceRow, 1, sourceParent);
    QString title= sourceModel()->data(titleIndex).toString();
    bool titleCheck = title.contains(m_titleFilter.toString());

    QModelIndex codeIndex= sourceModel()->index(sourceRow, 5, sourceParent);
    QString code = sourceModel()->data(codeIndex).toString();
    bool codeCheck = true;

    if(m_essentialsFilter.toBool()) {
        if(m_essentialsOnly.toBool()) {
            codeCheck &= code.endsWith(essentials_code_marker);
        }
    } else {
        codeCheck &= !code.endsWith(essentials_code_marker);
    }
    if(m_platinumFilter.toBool()) {
        if(m_platinumOnly.toBool()) {
            codeCheck &= code.endsWith(platinum_code_marker);
        }
    } else {
        codeCheck &= !code.endsWith(platinum_code_marker);
    }

    QModelIndex ownedIndex= sourceModel()->index(sourceRow, 7, sourceParent);
    int owned = sourceModel()->data(ownedIndex).toInt();
    bool ownedCheck = (m_ownedFilter.toInt() == owned) || (m_ownedFilter.toInt() >= 2);

    return titleCheck && codeCheck && ownedCheck;
}

bool SortFilterProxyModel::getEssentialsFilter() const
{
    return m_essentialsFilter.isValid() ?
               m_essentialsFilter.toBool() : true;
}

bool SortFilterProxyModel::getEssentialsOnly() const
{
    return m_essentialsOnly.isValid() ?
               m_essentialsOnly.toBool() : false;
}

bool SortFilterProxyModel::getPlatinumFilter() const
{
    return m_platinumFilter.isValid() ?
               m_platinumFilter.toBool() : true;
}

bool SortFilterProxyModel::getPlatinumOnly() const
{
    return m_platinumOnly.isValid() ?
               m_platinumOnly.toBool() : false;
}

QString SortFilterProxyModel::getTitleFilter() const
{
    return m_titleFilter.isValid() ?
               m_titleFilter.toString() : "";
}

int SortFilterProxyModel::getOwnedFilter() const
{
    return m_ownedFilter.isValid() ?
               m_ownedFilter.toInt() : 2;
}

int SortFilterProxyModel::getSortOrder() const
{
    return m_sortOrder.isValid() ?
               m_sortOrder.toInt() : 0;
}

int SortFilterProxyModel::getOrderBy() const
{
    return m_orderBy.isValid() ?
               m_orderBy.toInt() : 1;
}
