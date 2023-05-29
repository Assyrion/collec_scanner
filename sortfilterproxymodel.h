#ifndef SORTFILTERPROXYMODEL_H
#define SORTFILTERPROXYMODEL_H

#include <QSortFilterProxyModel>

class SortFilterProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT

public:
    explicit SortFilterProxyModel(QObject *parent = nullptr);

    // Header:
//    QVariant headerData(int section, Qt::Orientation orientation, int role = Qt::DisplayRole) const override;

//    bool setHeaderData(int section, Qt::Orientation orientation, const QVariant &value, int role = Qt::EditRole) override;

//    // Basic functionality:
//    QModelIndex index(int row, int column,
//                      const QModelIndex &parent = QModelIndex()) const override;
//    QModelIndex parent(const QModelIndex &index) const override;

//    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
//    int columnCount(const QModelIndex &parent = QModelIndex()) const override;

//    // Fetch data dynamically:
//    bool hasChildren(const QModelIndex &parent = QModelIndex()) const override;

//    bool canFetchMore(const QModelIndex &parent) const override;
//    void fetchMore(const QModelIndex &parent) override;

//    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

//    // Editable:
//    bool setData(const QModelIndex &index, const QVariant &value,
//                 int role = Qt::EditRole) override;

//    Qt::ItemFlags flags(const QModelIndex& index) const override;

//    // Add data:
//    bool insertRows(int row, int count, const QModelIndex &parent = QModelIndex()) override;
//    bool insertColumns(int column, int count, const QModelIndex &parent = QModelIndex()) override;

//    // Remove data:
//    bool removeRows(int row, int count, const QModelIndex &parent = QModelIndex()) override;
//    bool removeColumns(int column, int count, const QModelIndex &parent = QModelIndex()) override;

    Q_INVOKABLE void setOrderBy(int column, int order);

    Q_INVOKABLE void filterByOwned(bool owned, bool notOwned);
    Q_INVOKABLE void filterByTitle(const QString& title);
    Q_INVOKABLE void filterOnlyEssentials(bool filter);
    Q_INVOKABLE void filterOnlyPlatinum(bool filter);
    Q_INVOKABLE void filterEssentials(bool filter);
    Q_INVOKABLE void filterPlatinum(bool filter);

private:
};

#endif // SORTFILTERPROXYMODEL_H
