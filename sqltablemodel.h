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
    SqlTableModel(QObject* parent = nullptr);
    ~SqlTableModel() Q_DECL_OVERRIDE;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const Q_DECL_OVERRIDE;
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) Q_DECL_OVERRIDE;
    QHash<int, QByteArray> roleNames() const Q_DECL_OVERRIDE;
    QStringList roleNamesList() const;

    Q_INVOKABLE int getIndexNotFiltered(const QString &tag);
    Q_INVOKABLE void saveDBToFile(FileManager* fileManager);
    Q_INVOKABLE int getIndexFiltered(const QString &tag);

    Q_INVOKABLE void insert(GameData* game);
    Q_INVOKABLE void remove(int row);
    Q_INVOKABLE void clearDB();

    void sort(int column, Qt::SortOrder order = Qt::AscendingOrder) Q_DECL_OVERRIDE;

private:

    QHash<int, QByteArray> m_roles;

signals:

    void roleNamesListChanged();


};

#endif // SQLTABLEMODEL_H
