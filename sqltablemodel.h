#ifndef SQLTABLEMODEL_H
#define SQLTABLEMODEL_H

#include <QSqlTableModel>
#include <QSqlQuery>

class GameData;
class FileManager;
class SqlTableModel : public QSqlQueryModel
{
    Q_OBJECT

    Q_PROPERTY(bool essentialsFilter MEMBER m_essentialsFilter NOTIFY essentialsFilterChanged)
    Q_PROPERTY(bool essentialsOnly MEMBER m_essentialsOnly NOTIFY essentialsOnlyChanged)
    Q_PROPERTY(bool platinumFilter MEMBER m_platinumFilter NOTIFY platinumFilterChanged)
    Q_PROPERTY(bool platinumOnly MEMBER m_platinumOnly NOTIFY platinumOnlyChanged)
    Q_PROPERTY(QString titleFilter MEMBER m_titleFilter NOTIFY titleFilterChanged)
    Q_PROPERTY(int ownedFilter MEMBER m_ownedFilter NOTIFY ownedFilterChanged)
    Q_PROPERTY(int sortOrder MEMBER m_sortOrder NOTIFY sortOrderChanged)
    Q_PROPERTY(int orderBy MEMBER m_orderBy NOTIFY orderByChanged)

    Q_PROPERTY(QStringList roleNamesList READ roleNamesList NOTIFY roleNamesListChanged)

public:
    SqlTableModel(int orderBy, int sortOrder, const QString &titleFilter, int ownedFilter, bool essentialsFilter, bool platinumFilter, bool essentialsOnly, bool platinumOnly, QObject* parent = nullptr);
    ~SqlTableModel() Q_DECL_OVERRIDE;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const Q_DECL_OVERRIDE;
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) Q_DECL_OVERRIDE;
    QHash<int, QByteArray> roleNames() const Q_DECL_OVERRIDE;
    QStringList roleNamesList() const;

    Q_INVOKABLE void filterByOwned(bool owned, bool notOwned);
    Q_INVOKABLE int getIndexNotFiltered(const QString &tag);
    Q_INVOKABLE void saveDBToFile(FileManager* fileManager);
    Q_INVOKABLE int getIndexFiltered(const QString &tag);
    Q_INVOKABLE void filterByTitle(const QString& title);
    Q_INVOKABLE void setOrderBy(int column, int order);
    Q_INVOKABLE void update(int row, GameData* game);
    Q_INVOKABLE void filterOnlyEssentials(bool filter);
    Q_INVOKABLE void filterOnlyPlatinum(bool filter);
    Q_INVOKABLE void filterEssentials(bool filter);
    Q_INVOKABLE void filterPlatinum(bool filter);
    Q_INVOKABLE void insert(GameData* game);
    Q_INVOKABLE void remove(int row);
    Q_INVOKABLE void removeFilter();
    Q_INVOKABLE void clearDB();

    QString getTitleFilter() const;
    bool getEssentialsFilter() const;
    bool getEssentialsOnly() const;
    bool getPlatinumFilter() const;
    bool getPlatinumOnly() const;
    int getOwnedFilter() const;
    int getSortOrder() const;
    int getOrderBy() const;

private:

    void applyFilter();

    QHash<int, QByteArray> m_roles;
    bool m_essentialsFilter;
    bool m_essentialsOnly;
    bool m_platinumFilter;
    bool m_platinumOnly;
    QString m_titleFilter;
    int m_ownedFilter;
    int m_sortOrder;
    int m_orderBy;


signals:
    void roleNamesListChanged();
    void essentialsFilterChanged();
    void essentialsOnlyChanged();
    void platinumFilterChanged();
    void platinumOnlyChanged();
    void titleFilterChanged();
    void ownedFilterChanged();
    void sortOrderChanged();
    void orderByChanged();
};

#endif // SQLTABLEMODEL_H
