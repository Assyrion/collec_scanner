#include "codefilterproxymodel.h"

CodeFilterProxyModel::CodeFilterProxyModel(QString code, QObject* parent)
    : QSortFilterProxyModel(parent), m_baseCode(code)
{}

CodeFilterProxyModel::~CodeFilterProxyModel()
{}

int CodeFilterProxyModel::mapIndexToSource(int idx)
{
    QModelIndex sourceIdx = mapToSource(index(idx, 0));
    return sourceIdx.row();
}

bool CodeFilterProxyModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    QModelIndex codeIndex= sourceModel()->index(sourceRow, 5, sourceParent);
    QString code = sourceModel()->data(codeIndex).toString();

    return code.contains(m_baseCode);
}
