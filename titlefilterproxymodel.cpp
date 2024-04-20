#include "titlefilterproxymodel.h"

TitleFilterProxyModel::TitleFilterProxyModel(const QString& title, QObject* parent)
    : QSortFilterProxyModel(parent)
{
    setFilterKeyColumn(1);
    setFilterRegularExpression(QString("^%1$|^%1 \\(").arg(QRegularExpression::escape(title)));
}

TitleFilterProxyModel::~TitleFilterProxyModel()
{}

int TitleFilterProxyModel::mapIndexToSource(int idx)
{
    QModelIndex sourceIdx = mapToSource(index(idx, 0));
    return sourceIdx.row();
}
