#ifndef DBMANAGER_H
#define DBMANAGER_H

#include <QObject>
#include <QDebug>
#include <QSqlDatabase>

class DBManager : public QObject
{
    Q_OBJECT
public:
    explicit DBManager(QObject *parent = nullptr);

    Q_INVOKABLE void addEntry(QString barcode, QString title);
    Q_INVOKABLE QString getEntry(QString barcode);

private:
    QSqlDatabase m_db;

signals:

public slots:
};

#endif // DBMANAGER_H
