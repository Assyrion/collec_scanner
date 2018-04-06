#ifndef DBMANAGER_H
#define DBMANAGER_H

#include <QObject>
#include <QDebug>
#include <QSqlDatabase>

class GameData;
class DBManager : public QObject
{
    Q_OBJECT
public:
    explicit DBManager(QObject *parent = nullptr);

    Q_INVOKABLE void addEntry(GameData* game);
    Q_INVOKABLE GameData* getEntry(QString tag);

private:
    QSqlDatabase m_db;

signals:

public slots:
};

#endif // DBMANAGER_H
