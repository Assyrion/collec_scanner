#include "sqltablemodel.h"
#include "filemanager.h"
#include "gamedata.h"

#include <QSqlDriver>
#include <QSqlRecord>
#include <QSqlField>

#include <QDebug>

SqlTableModel::SqlTableModel(QObject* parent)
    : QSqlTableModel(parent)
{
    setTable("games");
    setEditStrategy(OnFieldChange);
    setFilter("");

    auto rec = record();
    for(int i = 0; i < rec.count(); i++) {
        m_roles.insert(Qt::UserRole + i + 1, rec.fieldName(i).toUtf8());
    }
    select();
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

void SqlTableModel::setFilter(const QString &filter)
{
    if(filter.isEmpty()) {
        QSqlTableModel::setFilter("1=1 ORDER BY title COLLATE NOCASE ASC"); // default filter
    } else {
        QSqlTableModel::setFilter(filter);
    }
}

void SqlTableModel::remove(int row)
{
    if(row < 0 || row >= rowCount()) {
        return;
    }
    removeRow(row);
    select();
}

void SqlTableModel::update(int row, GameData* game)
{
    if(!game || row >= rowCount())
        return;

    if(row < 0) {
        auto list = match(this->index(0, 0), Qt::UserRole + 1, game->tag);
        if(list.count() > 1) {
            return;
        }
        if(list.count() == 1) {
            row = list[0].row();
        }
    }

    QSqlRecord rec = record();
    rec.setValue("tag",          game->tag);
    rec.setValue("title",        game->title);
    rec.setValue("full_title",   game->full_title);
    rec.setValue("platform",     game->platform);
    rec.setValue("publisher",    game->publisher);
    rec.setValue("developer",    game->developer);
    rec.setValue("release_date", game->release_date);
    rec.setValue("info",         game->info);

    if(row < 0) {
        insertRecord(row, rec);
    } else {
        setRecord(row, rec);
    }
    select();
}

GameData* SqlTableModel::get(const QString& tag)
{
    setFilter("tag = \'" + tag + "\'");

    GameData* game = nullptr;

    if(rowCount() == 1) {
        QSqlRecord rec = record(0);
        auto list = { tag,
                      rec.value(1).toString(),
                      rec.value(2).toString(),
                      rec.value(3).toString(),
                      rec.value(4).toString(),
                      rec.value(5).toString(),
                      rec.value(6).toString(),
                      rec.value(7).toString()};
        game = GameDataMaker::get()->createComplete(list);
    }

    setFilter("");

    return game;
}

void SqlTableModel::filterByTitle(const QString &title)
{
    if(title.isEmpty()) {
        setFilter("");
        return;
    }

    setFilter("title LIKE \'%" + title + "%\'");
}

void SqlTableModel::saveDBToFile(FileManager* fileManager)
{
    if(!fileManager) {
        return;
    }
    for(int r = 0; r < rowCount(); r++) {
        QStringList list;
        for(int c = 0; c < columnCount(); c++) {
            list.append(data(index(r, c), 0).toString());
        }
        auto game = GameDataMaker::get()->createComplete(list);
        fileManager->addEntry(game);
    }
}
