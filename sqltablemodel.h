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

    QVariant data(const QModelIndex &index, int role) const Q_DECL_OVERRIDE;
    QHash<int, QByteArray> roleNames() const Q_DECL_OVERRIDE;
    QStringList roleNamesList() const;

    Q_INVOKABLE void remove(int row, const QString &tag);
    Q_INVOKABLE void update(int row, GameData* game);
    Q_INVOKABLE int getIndex(const QString &tag);
    Q_INVOKABLE void filterByTitle(const QString& title);
    Q_INVOKABLE void orderBy(int column, int order);
    Q_INVOKABLE void saveDBToFile(FileManager* fileManager);

private:
    QHash<int, QByteArray> m_roles;

signals:
    void roleNamesListChanged();
};

#endif // SQLTABLEMODEL_H
