#ifndef CODEFILTERPROXYMODEL_H
#define CODEFILTERPROXYMODEL_H

#include <QSortFilterProxyModel>

class CodeFilterProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT

public:
    explicit CodeFilterProxyModel(QString code, QObject* parent = nullptr);

    ~CodeFilterProxyModel();

    Q_INVOKABLE int mapIndexToSource(int idx);

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const Q_DECL_OVERRIDE;

private:
    QString m_baseCode;
};
#endif // CODEFILTERPROXYMODEL_H
