#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QObject>
#include <QHash>

#include "sqltablemodel.h"

class DatabaseManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(SqlTableModel* currentSQLModel READ currentSQLModel NOTIFY currentSQLModelChanged)

public:
    explicit DatabaseManager(QObject *parent = nullptr);
    int loadDB(const QString& platform);

    SqlTableModel* currentSQLModel() const;

private:
    QHash<QString, SqlTableModel*> m_modelHash;

    SqlTableModel* m_currentSQLModel;

signals:
    void currentSQLModelChanged();
    void unknownDatabase();
};

#endif // DATABASEMANAGER_H
