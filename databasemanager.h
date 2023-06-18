#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QObject>
#include <QHash>

#include "sqltablemodel.h"
#include "sortfilterproxymodel.h"

class DatabaseManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(SqlTableModel* currentSqlModel READ currentSqlModel NOTIFY databaseChanged)
    Q_PROPERTY(SortFilterProxyModel* currentProxyModel READ currentProxyModel NOTIFY databaseChanged)

public:
    explicit DatabaseManager(QHash<QString, QVariantHash>& paramHash, QObject *parent = nullptr);
    virtual ~DatabaseManager();

    Q_INVOKABLE int loadDB(const QString& platform);
    Q_INVOKABLE int reloadDB(const QString& platform);

    SqlTableModel* currentSqlModel() const;
    SortFilterProxyModel* currentProxyModel() const;

private:
    QHash<QString, SortFilterProxyModel*> m_modelHash;
    QHash<QString, QVariantHash>& m_paramHash;

    SortFilterProxyModel* m_currentProxyModel;

signals:
    void databaseChanged();
    void unknownDatabase();
};

#endif // DATABASEMANAGER_H
