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
    Q_PROPERTY(QString filter MEMBER m_filter NOTIFY filterChanged)
    Q_PROPERTY(int orderBy MEMBER m_orderBy NOTIFY orderByChanged)

public:
    SqlTableModel(int orderBy, int sortOrder, const QString &filter, QObject* parent = nullptr);
    ~SqlTableModel() Q_DECL_OVERRIDE;

    QVariant data(const QModelIndex &index, int role) const Q_DECL_OVERRIDE;
    QHash<int, QByteArray> roleNames() const Q_DECL_OVERRIDE;
    QStringList roleNamesList() const;

    Q_INVOKABLE void remove(int row, const QString &tag);
    Q_INVOKABLE void update(int row, GameData* game);
    Q_INVOKABLE int getIndexFiltered(const QString &tag);
    Q_INVOKABLE int getIndexNotFiltered(const QString &tag);
    Q_INVOKABLE void filterByTitle(const QString& title);
    Q_INVOKABLE void setOrderBy(int column, int order);
    Q_INVOKABLE void saveDBToFile(FileManager* fileManager);

    QString filter() const;
    int sortOrder() const;
    int orderBy() const;

private:
    QHash<int, QByteArray> m_roles;
    QString m_filter;
    int m_sortOrder;
    int m_orderBy;

signals:
    void roleNamesListChanged();
    void sortOrderChanged();
    void orderByChanged();
    void filterChanged();
};

#endif // SQLTABLEMODEL_H
