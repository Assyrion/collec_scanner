#include "sqltablemodel.h"
#include <QSqlDriver>
#include <QSqlRecord>
#include <QSqlField>

#include <QDebug>

SqlTableModel::SqlTableModel()
{
    setTable("games");
    select();

    auto rec = record();
    for(int i = 0; i < rec.count(); i++) {
        //        setHeaderData(i, Qt::Horizontal, rec.fieldName(i));
        m_roles.insert(Qt::UserRole + i + 1, rec.fieldName(i).toUtf8());
        m_headers.push_back(rec.fieldName(i));
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
    QVariant value;

    if (index.isValid()) {
        if (role < Qt::UserRole) {
            value = QSqlQueryModel::data(index, role);
        } else {
            int columnIdx = role - Qt::UserRole - 1;
            QModelIndex modelIndex = this->index(index.row(), columnIdx);
            value = QSqlQueryModel::data(modelIndex, Qt::DisplayRole);
        }
    }
    return value;
}

bool SqlTableModel::setData(const QModelIndex &item, const QVariant &value, int role)
{
    if (item.isValid() && role == Qt::EditRole) {
        QSqlRecord rec = record(item.row());
        rec.setGenerated(item.column(), true);

        if(!value.isNull()) {
            rec.setValue(item.column(), value);
        } else {
            rec.setNull(item.column());
        }

        updateRowInTable(item.row(), rec); // dirty but don't know how to do otherwise
        emit dataChanged(item, item);
        return true;
    }
    return false;
}

QVariant SqlTableModel::headerData(int section, Qt::Orientation orientation, int role) const
{
    if(role < Qt::UserRole) {
        return QAbstractItemModel::headerData(section, orientation, role);
    }
    return m_roles.value(role);
}

void SqlTableModel::setMapping(QObject *object, int role, const QByteArray &property)
{
    if(object) {
        object->setProperty(property, data(this->index(0, 0), Qt::UserRole+1));
    }
}

