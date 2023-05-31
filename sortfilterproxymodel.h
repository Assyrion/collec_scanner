#ifndef SORTFILTERPROXYMODEL_H
#define SORTFILTERPROXYMODEL_H

#include <QSortFilterProxyModel>

class SortFilterProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT

    Q_PROPERTY(bool essentialsFilter MEMBER m_essentialsFilter NOTIFY essentialsFilterChanged)
    Q_PROPERTY(bool essentialsOnly MEMBER m_essentialsOnly NOTIFY essentialsOnlyChanged)
    Q_PROPERTY(bool platinumFilter MEMBER m_platinumFilter NOTIFY platinumFilterChanged)
    Q_PROPERTY(bool platinumOnly MEMBER m_platinumOnly NOTIFY platinumOnlyChanged)
    Q_PROPERTY(QString titleFilter MEMBER m_titleFilter NOTIFY titleFilterChanged)
    Q_PROPERTY(int ownedFilter MEMBER m_ownedFilter NOTIFY ownedFilterChanged)
    Q_PROPERTY(int sortOrder MEMBER m_sortOrder NOTIFY sortOrderChanged)
    Q_PROPERTY(int orderBy MEMBER m_orderBy NOTIFY orderByChanged)

public:
    explicit SortFilterProxyModel(int orderBy, int sortOrder, const QString &titleFilter, int ownedFilter, bool essentialsFilter, bool platinumFilter, bool essentialsOnly, bool platinumOnly, QObject *parent = nullptr);

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

    QString getTitleFilter() const;
    bool getEssentialsFilter() const;
    bool getEssentialsOnly() const;
    bool getPlatinumFilter() const;
    bool getPlatinumOnly() const;
    int getOwnedFilter() const;
    int getSortOrder() const;
    int getOrderBy() const;

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const Q_DECL_OVERRIDE;

private:
    bool m_essentialsFilter;
    bool m_essentialsOnly;
    bool m_platinumFilter;
    bool m_platinumOnly;
    QString m_titleFilter;
    int m_ownedFilter;
    int m_sortOrder;
    int m_orderBy;


signals:
    void essentialsFilterChanged();
    void essentialsOnlyChanged();
    void platinumFilterChanged();
    void platinumOnlyChanged();
    void titleFilterChanged();
    void ownedFilterChanged();
    void sortOrderChanged();
    void orderByChanged();
};

#endif // SORTFILTERPROXYMODEL_H
