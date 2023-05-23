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
    Q_PROPERTY(int sortOrder MEMBER m_sortOrder NOTIFY sortOrderChanged)
    Q_PROPERTY(QString titleFilter MEMBER m_titleFilter NOTIFY titleFilterChanged)
    Q_PROPERTY(int ownedFilter MEMBER m_ownedFilter NOTIFY ownedFilterChanged)
    Q_PROPERTY(int orderBy MEMBER m_orderBy NOTIFY orderByChanged)

public:
    SqlTableModel(int orderBy, int sortOrder, const QString &titleFilter, int ownedFilter, QObject* parent = nullptr);
    ~SqlTableModel() Q_DECL_OVERRIDE;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const Q_DECL_OVERRIDE;
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) Q_DECL_OVERRIDE;
    QHash<int, QByteArray> roleNames() const Q_DECL_OVERRIDE;
    QStringList roleNamesList() const;

    Q_INVOKABLE void insert(GameData* game);
    Q_INVOKABLE void remove(int row);
    Q_INVOKABLE void update(int row, GameData* game);
    Q_INVOKABLE int getIndexFiltered(const QString &tag);
    Q_INVOKABLE int getIndexNotFiltered(const QString &tag);
    Q_INVOKABLE void filterByTitle(const QString& title);
    Q_INVOKABLE void filterByOwned(bool owned, bool notOwned);
    Q_INVOKABLE void setOrderBy(int column, int order);
    Q_INVOKABLE void saveDBToFile(FileManager* fileManager);
    Q_INVOKABLE void clearDB();

    QString getTitleFilter() const;
    int getOwnedFilter() const;
    int getSortOrder() const;
    int getOrderBy() const;

private:

    void applyFilter();

    QHash<int, QByteArray> m_roles;
    QString m_titleFilter;
    int m_ownedFilter;
    int m_sortOrder;
    int m_orderBy;

signals:
    void roleNamesListChanged();
    void sortOrderChanged();
    void orderByChanged();
    void titleFilterChanged();
    void ownedFilterChanged();
};

#endif // SQLTABLEMODEL_H
