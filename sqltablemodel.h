#ifndef SQLTABLEMODEL_H
#define SQLTABLEMODEL_H

#include <QSqlTableModel>
#include <QSqlQuery>

class GameData;
class FileManager;
class SqlTableModel : public QSqlTableModel
{
    Q_OBJECT

    Q_PROPERTY(QStringList roleNamesList READ roleNamesList NOTIFY roleNamesListChanged)

public:
    SqlTableModel(QObject* parent = nullptr, const QSqlDatabase &db = QSqlDatabase());
    ~SqlTableModel() Q_DECL_OVERRIDE;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const Q_DECL_OVERRIDE;
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) Q_DECL_OVERRIDE;
    QHash<int, QByteArray> roleNames() const Q_DECL_OVERRIDE;
    QStringList roleNamesList() const;

    Q_INVOKABLE void updateData(const QModelIndex &index, const QVariantList &data);

    Q_INVOKABLE void saveDBToFile(FileManager* fileManager);

private:

    QHash<int, QByteArray> m_roles;

signals:

    void roleNamesListChanged();
};

#endif // SQLTABLEMODEL_H
