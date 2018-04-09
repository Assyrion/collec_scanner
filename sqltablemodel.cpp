#include "sqltablemodel.h"
#include <QSqlDriver>
#include <QSqlRecord>
#include <QSqlField>

#include <QDebug>

SqlTableModel::SqlTableModel()
{
    setTable("games");
    select();
    QSqlRecord rec = database().driver()->record(tableName());
    for(int i =0; i < rec.count(); i++)
        qDebug() << rec.field(0);
    setHeaderData(0, Qt::Horizontal, tr("tag"));
    setHeaderData(1, Qt::Horizontal, tr("title"));
}

SqlTableModel::~SqlTableModel()
{

}
