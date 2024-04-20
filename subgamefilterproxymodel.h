#ifndef SUBGAMEFILTERPROXYMODEL_H
#define SUBGAMEFILTERPROXYMODEL_H

#include <QSortFilterProxyModel>

class SubgameFilterProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT

public:
    explicit SubgameFilterProxyModel(QObject *parent = nullptr);
    ~SubgameFilterProxyModel() Q_DECL_OVERRIDE;

    Q_INVOKABLE int mapIndexFromSource(int sourceIdx);
    Q_INVOKABLE int mapIndexToSource(int idx);
};

#endif // SUBGAMEFILTERPROXYMODEL_H
