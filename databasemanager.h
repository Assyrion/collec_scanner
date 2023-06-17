#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QObject>
#include <QHash>

#include "sqltablemodel.h"
#include "sortfilterproxymodel.h"

class DatabaseManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(SqlTableModel* currentSqlModel READ currentSqlModel NOTIFY currentSqlModelChanged)
    Q_PROPERTY(SortFilterProxyModel* currentProxyModel READ currentProxyModel NOTIFY currentProxyModelChanged)

public:
    explicit DatabaseManager(QHash<QString, QVariantHash>& paramHash, QObject *parent = nullptr);
    virtual ~DatabaseManager();

    int loadDB(const QString& platform);

    SqlTableModel* currentSqlModel() const;
    SortFilterProxyModel* currentProxyModel() const;

private:
    QHash<QString, SortFilterProxyModel*> m_modelHash;
    QHash<QString, QVariantHash>& m_paramHash;

    SqlTableModel* m_currentSqlModel;
    SortFilterProxyModel* m_currentProxyModel;

signals:
    void currentSqlModelChanged();
    void currentProxyModelChanged();

    void unknownDatabase();
};

#endif // DATABASEMANAGER_H
