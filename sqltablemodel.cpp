#include "sqltablemodel.h"
#include "gamedata.h"

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
        m_roles.insert(Qt::UserRole + i + 1, rec.fieldName(i).toUtf8());
    }

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

void SqlTableModel::update(int row, GameData* game)
{
    if(!game || row >= rowCount())
        return;

    QSqlRecord rec = record(row);
    rec.setValue("title",        game->title);
    rec.setValue("platform",     game->platform);
    rec.setValue("publisher",    game->publisher);
    rec.setValue("developer",    game->developer);
    rec.setValue("release_date", game->releaseDate);

    if(row < 0) {
        insertRecord(row, rec);
    } else {
        setRecord(row, rec);
    }
//    selectRow(row); // does not work ??
    select();
}

GameData* SqlTableModel::get(const QString& tag)
{
    setFilter("tag = " + tag);

    GameData* game;
    if(rowCount() != 1) {
        game = GameDataMaker::get()->createNew(tag);
    } else {
        QSqlRecord rec = record(0);
        auto list = { tag,
                    rec.value(1).toString(), // need to add 2 = full_title
                    rec.value(3).toString(),
                    rec.value(4).toString(),
                    rec.value(5).toString(),
                    rec.value(6).toString()};
        game = GameDataMaker::get()->createComplete(list);
    }

    setFilter(""); // remove filter

    return game;
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

        emit dataChanged(item, item);
        updateRowInTable(item.row(), rec); // dirty but don't know how to do otherwise
        return true;
    }
    return false;
}
