#ifndef SQLTABLEMODEL_H
#define SQLTABLEMODEL_H
#include <QSqlTableModel>

class GameData;
class SqlTableModel : public QSqlTableModel
{
    Q_OBJECT
public:
    SqlTableModel(QObject* parent = nullptr);
    ~SqlTableModel() Q_DECL_OVERRIDE;

    QHash<int, QByteArray> roleNames() const Q_DECL_OVERRIDE;
    QVariant data(const QModelIndex &index, int role) const Q_DECL_OVERRIDE;

    Q_INVOKABLE void remove(int row);
    Q_INVOKABLE void update(int row, GameData* game);
    Q_INVOKABLE GameData* get(const QString &tag);

private:
    QHash<int, QByteArray> m_roles;
};

#endif // SQLTABLEMODEL_H
