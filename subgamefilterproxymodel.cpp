#include "subgamefilterproxymodel.h"

SubgameFilterProxyModel::SubgameFilterProxyModel(QObject *parent)
    : QSortFilterProxyModel{parent}
{
    setFilterRole(Qt::UserRole + 9);
    setFilterRegularExpression(QString("^(?!2$)"));
}

SubgameFilterProxyModel::~SubgameFilterProxyModel()
{}

int SubgameFilterProxyModel::mapIndexFromSource(int sourceIdx)
{
    QModelIndex idx = mapFromSource(sourceModel()->index(sourceIdx, 0));
    return idx.row();
}

int SubgameFilterProxyModel::mapIndexToSource(int idx)
{
    QModelIndex sourceIdx = mapToSource(index(idx, 0));
    return sourceIdx.row();
}
