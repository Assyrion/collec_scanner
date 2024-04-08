#ifndef SORTFILTERPROXYMODEL_H
#define SORTFILTERPROXYMODEL_H

#include <QSortFilterProxyModel>
#include "titlefilterproxymodel.h"

class SortFilterProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT

    Q_PROPERTY(bool essentialsFilter READ getEssentialsFilter NOTIFY essentialsFilterChanged)
    Q_PROPERTY(bool essentialsOnly READ getEssentialsOnly NOTIFY essentialsOnlyChanged)
    Q_PROPERTY(bool platinumFilter READ getPlatinumFilter NOTIFY platinumFilterChanged)
    Q_PROPERTY(bool platinumOnly READ getPlatinumOnly NOTIFY platinumOnlyChanged)
    Q_PROPERTY(QString titleFilter READ getTitleFilter NOTIFY titleFilterChanged)
    Q_PROPERTY(int ownedFilter READ getOwnedFilter NOTIFY ownedFilterChanged)
    Q_PROPERTY(bool palFilter READ getPalFilter NOTIFY palFilterChanged)
    Q_PROPERTY(int sortOrder READ getSortOrder NOTIFY sortOrderChanged)
    Q_PROPERTY(bool frFilter READ getFrFilter NOTIFY frFilterChanged)
    Q_PROPERTY(bool groupVar READ getGroupVar NOTIFY groupVarChanged)
    Q_PROPERTY(int orderBy READ getOrderBy NOTIFY orderByChanged)

public:
    explicit SortFilterProxyModel(QVariantHash &params, /*int orderBy, int sortOrder, const QString &titleFilter,
                                  int ownedFilter, bool essentialsFilter = true, bool platinumFilter = true,
                                  bool essentialsOnly = false, bool platinumOnly = false, */QObject *parent = nullptr);
    ~SortFilterProxyModel() Q_DECL_OVERRIDE;

    void sort(int column, Qt::SortOrder order = Qt::AscendingOrder) Q_DECL_OVERRIDE;
    void setSourceModel(QAbstractItemModel *sourceModel) Q_DECL_OVERRIDE;

    Q_INVOKABLE int getIndexFiltered(const QString &tag);
    Q_INVOKABLE int getIndexNotFiltered(const QString &tag);

    Q_INVOKABLE void filterByOwned(bool owned, bool notOwned);
    Q_INVOKABLE void filterByTitle(const QString& title);
    Q_INVOKABLE void filterOnlyEssentials(bool filter);
    Q_INVOKABLE void filterOnlyPlatinum(bool filter);
    Q_INVOKABLE void filterEssentials(bool filter);
    Q_INVOKABLE void filterPlatinum(bool filter);
    Q_INVOKABLE void filterPal(bool filter);
    Q_INVOKABLE void filterFr(bool filter);

    Q_INVOKABLE void setGroupVar(bool groupVar);

    Q_INVOKABLE void resetFilter();

    bool getEssentialsFilter() const;
    bool getEssentialsOnly() const;
    bool getPlatinumFilter() const;
    bool getPlatinumOnly() const;
    QString getTitleFilter() const;
    int getOwnedFilter() const;
    bool getPalFilter() const;
    bool getFrFilter() const;
    int getSortOrder() const;
    int getGroupVar() const;
    int getOrderBy() const;

    Q_INVOKABLE TitleFilterProxyModel* getTitleFilterProxyModel(const QString& title);

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const Q_DECL_OVERRIDE;

private:
    QVariant& m_essentialsFilter;
    QVariant& m_essentialsOnly;
    QVariant& m_platinumFilter;
    QVariant& m_platinumOnly;
    QVariant& m_titleFilter;
    QVariant& m_ownedFilter;
    QVariant& m_sortOrder;
    QVariant& m_palFilter;
    QVariant& m_frFilter;
    QVariant& m_groupVar;
    QVariant& m_orderBy;

    QHash<QString, TitleFilterProxyModel*> m_titleFilterProxyMap;

    void rebuildTitleMap();
    void prepareInvalidateFilter();

signals:
    void essentialsFilterChanged();
    void essentialsOnlyChanged();
    void platinumFilterChanged();
    void platinumOnlyChanged();
    void titleFilterChanged();
    void ownedFilterChanged();
    void sortOrderChanged();
    void palFilterChanged();
    void frFilterChanged();
    void groupVarChanged();
    void orderByChanged();

    void titleMappingChanged();
};

#endif // SORTFILTERPROXYMODEL_H
