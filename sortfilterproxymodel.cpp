#include "sortfilterproxymodel.h"
#include "titlefilterproxymodel.h"

const QString platinum_code_marker = "/P";
const QString essentials_code_marker = "/E";

SortFilterProxyModel::SortFilterProxyModel(QVariantHash &params, QObject *parent)
    : QSortFilterProxyModel(parent), m_essentialsFilter(params["essentialsFilter"]),
    m_essentialsOnly(params["essentialsOnly"]),
    m_platinumFilter(params["platinumFilter"]),
    m_platinumOnly(params["platinumOnly"]),
    m_titleFilter(params["titleFilter"]),
    m_ownedFilter(params["ownedFilter"]),
    m_sortOrder(params["sortOrder"]),
    m_palFilter(params["palFilter"]),
    m_frFilter(params["frFilter"]),
    m_groupVar(params["groupVar"]),
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
    m_groupVar = getGroupVar();
    m_orderBy = getOrderBy();
}

SortFilterProxyModel::~SortFilterProxyModel()
{
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

    prepareInvalidateFilter();
}

void SortFilterProxyModel::resetFilter()
{
    m_essentialsFilter = true;
    m_platinumFilter = true;
    m_essentialsOnly = false;
    m_platinumOnly = false;
    m_palFilter = false;
    m_frFilter = false;
    m_titleFilter = "";
    m_ownedFilter = 2;

    emit essentialsFilterChanged();
    emit essentialsOnlyChanged();
    emit platinumFilterChanged();
    emit platinumOnlyChanged();
    emit titleFilterChanged();
    emit ownedFilterChanged();
    emit palFilterChanged();
    emit frFilterChanged();

    prepareInvalidateFilter();
}

void SortFilterProxyModel::filterEssentials(bool filter)
{
    m_essentialsFilter = filter;
    emit essentialsFilterChanged();

    prepareInvalidateFilter();
}

void SortFilterProxyModel::filterOnlyEssentials(bool filter)
{
    m_essentialsOnly = filter;
    emit essentialsOnlyChanged();

    prepareInvalidateFilter();
}

void SortFilterProxyModel::filterPlatinum(bool filter)
{
    m_platinumFilter = filter;
    emit platinumFilterChanged();

    prepareInvalidateFilter();
}

void SortFilterProxyModel::filterPal(bool filter)
{
    m_palFilter = filter;
    emit palFilterChanged();

    prepareInvalidateFilter();
}

void SortFilterProxyModel::filterFr(bool filter)
{
    m_frFilter = filter;
    emit frFilterChanged();

    prepareInvalidateFilter();
}

void SortFilterProxyModel::setGroupVar(bool groupVar)
{
    m_groupVar = groupVar;
    emit groupVarChanged();

    prepareInvalidateFilter();
}

void SortFilterProxyModel::filterOnlyPlatinum(bool filter)
{
    m_platinumOnly = filter;
    emit platinumOnlyChanged();

    prepareInvalidateFilter();
}

void SortFilterProxyModel::filterByTitle(const QString &title)
{
    m_titleFilter = title;
    emit titleFilterChanged();

    prepareInvalidateFilter();
}

void SortFilterProxyModel::filterByOwned(bool owned, bool notOwned)
{
    m_ownedFilter = ((owned ? 0b10 : 0)
                  | (notOwned ? 0b01 : 0)) - 1;
    emit ownedFilterChanged();

    prepareInvalidateFilter();
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

TitleFilterProxyModel* SortFilterProxyModel::getTitleFilterProxyModel(const QString& title)
{
    if(!m_titleFilterProxyMap.contains(title)) {
        m_titleFilterProxyMap.insert(title, new TitleFilterProxyModel(this));

        m_titleFilterProxyMap[title]->setSourceModel(this);
        m_titleFilterProxyMap[title]->setFilterKeyColumn(1);
        m_titleFilterProxyMap[title]->setFilterRegularExpression(QString("^%1$|^%1 \\(")
                                                                     .arg(QRegularExpression::escape(title)));
    }

    return m_titleFilterProxyMap[title];
}

void SortFilterProxyModel::rebuildTitleMap()
{
    QHash<QString, QList<QPair<int, QString>>> hash;
    for (int row = 0; row < rowCount(); ++row) {

        setData(index(row, 0), 0, Qt::UserRole + 9); // becomes a single game

        auto title = data(index(row, 0), Qt::UserRole + 2).toString(); // get title

        QRegularExpression regex("^(.*?)(?:\\(|$)");
        QRegularExpressionMatch match = regex.match(title);

        if (match.hasMatch()) {
            QString titleCaptured = match.captured(1).trimmed();
            hash[titleCaptured] << qMakePair(row, title);
        }
    }
    hash.removeIf([](decltype(hash)::iterator i) { return i->count() == 1; }); // remove unique games

    for (auto it = hash.begin(); it != hash.end(); ++it) {
        auto& list = it.value();
        std::sort(list.begin(), list.end(),
                  [&](const auto &left, const auto &right) {
                      setData(index(left.first,  0), 2, Qt::UserRole + 9); // becomes a subgame
                      setData(index(right.first, 0), 2, Qt::UserRole + 9); // becomes a subgame
                      return left.second < right.second;
                  });

        setData(index(list[0].first, 0), 1, Qt::UserRole + 9); // becomes a container
    }
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

    QModelIndex infoIndex= sourceModel()->index(sourceRow, 6, sourceParent);
    QString info = sourceModel()->data(infoIndex).toString();
    bool infoCheck = true;

    if(m_palFilter.toBool()) {
        infoCheck &= info.contains("#PAL");

        if(m_frFilter.toBool()) {
            infoCheck &= info.contains("#FR");
        }
    }

    QModelIndex ownedIndex= sourceModel()->index(sourceRow, 7, sourceParent);
    int owned = sourceModel()->data(ownedIndex).toInt();
    bool ownedCheck = (m_ownedFilter.toInt() == owned) || (m_ownedFilter.toInt() >= 2);

    return titleCheck && codeCheck && infoCheck && ownedCheck;
}

void SortFilterProxyModel::prepareInvalidateFilter()
{
    invalidateRowsFilter();

    if(m_groupVar.toBool()) {
        beginResetModel();
        rebuildTitleMap();
        endResetModel();
    }
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

bool SortFilterProxyModel::getPalFilter() const
{
    return m_palFilter.isValid() ?
               m_palFilter.toBool() : false;
}

bool SortFilterProxyModel::getFrFilter() const
{
    return m_frFilter.isValid() ?
               m_frFilter.toBool() : false;
}

int SortFilterProxyModel::getSortOrder() const
{
    return m_sortOrder.isValid() ?
               m_sortOrder.toInt() : 0;
}

int SortFilterProxyModel::getGroupVar() const
{
    return m_groupVar.isValid() ?
               m_groupVar.toBool() : false;
}

int SortFilterProxyModel::getOrderBy() const
{
    return m_orderBy.isValid() ?
               m_orderBy.toInt() : 1;
}
