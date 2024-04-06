#ifndef TITLEFILTERPROXYMODEL_H
#define TITLEFILTERPROXYMODEL_H

#include <QSortFilterProxyModel>

class TitleFilterProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT

public:
    explicit TitleFilterProxyModel(QObject* parent = nullptr);
    ~TitleFilterProxyModel();

    Q_INVOKABLE int mapIndexToSource(int idx);

};
#endif // TITLEFILTERPROXYMODEL_H
