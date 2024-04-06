#include "titlefilterproxymodel.h"

TitleFilterProxyModel::TitleFilterProxyModel(QObject* parent)
    : QSortFilterProxyModel(parent)
{}

TitleFilterProxyModel::~TitleFilterProxyModel()
{}

int TitleFilterProxyModel::mapIndexToSource(int idx)
{
    QModelIndex sourceIdx = mapToSource(index(idx, 0));
    return sourceIdx.row();
}
