#ifndef SQLTABLEMODEL_H
#define SQLTABLEMODEL_H
#include <QSqlTableModel>

class SqlTableModel : public QSqlTableModel
{
    Q_OBJECT
    Q_PROPERTY(QStringList headers MEMBER m_headers NOTIFY headersChanged)
public:
    SqlTableModel();
    ~SqlTableModel() Q_DECL_OVERRIDE;

    QHash<int, QByteArray> roleNames() const Q_DECL_OVERRIDE;
    bool setData(const QModelIndex &index, const QVariant &value, int role) Q_DECL_OVERRIDE;
    QVariant data(const QModelIndex &index, int role) const Q_DECL_OVERRIDE;
    QVariant headerData(int section, Qt::Orientation orientation, int role) const Q_DECL_OVERRIDE;

private:
    QHash<int, QByteArray> m_roles;
    QStringList m_headers;

signals:
    void headersChanged();
};

#endif // SQLTABLEMODEL_H
