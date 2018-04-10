#include "sqltablemodel.h"
#include <QSqlDriver>
#include <QSqlRecord>
#include <QSqlField>

#include <QDebug>

SqlTableModel::SqlTableModel()
{
    setTable("games");
    select();
    QSqlRecord rec { database().record(tableName()) };
    for(int i = 1; i < rec.count(); i++) {
//        setHeaderData(i, Qt::Horizontal, rec.fieldName(i));
        m_headers.push_back(rec.fieldName(i));
        m_roles.insert(Qt::UserRole + i, qUtf8Printable(rec.fieldName(i)));
    }
//    emit headerDataChanged(Qt::Horizontal, 0, rec.count());
    emit headersChanged();
}

SqlTableModel::~SqlTableModel()
{}

QHash<int, QByteArray> SqlTableModel::roleNames() const
{
    return m_roles;
}

QVariant SqlTableModel::data(const QModelIndex &index, int role) const
{
    if(role < Qt::UserRole) {
        return QSqlQueryModel::data(index, role);
    }
    QSqlRecord r = record(index.row());
    return r.value(QString(m_roles.value(role))).toString();
}

QVariant SqlTableModel::headerData(int section, Qt::Orientation orientation, int role) const
{
    if(role < Qt::UserRole) {
        return QAbstractItemModel::headerData(section, orientation, role);
    }
    return m_roles.value(role);
}
