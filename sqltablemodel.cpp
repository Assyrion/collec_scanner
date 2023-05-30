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
    setEditStrategy(QSqlTableModel::OnFieldChange);
    setTable("games");

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

QStringList SqlTableModel::roleNamesList() const
{
    QStringList names;
    for(int i=0; i<record().count(); i++) {
        names << record().fieldName(i);
    }
    return names;
}

QVariant SqlTableModel::data(const QModelIndex &index, int role) const
{
    if (index.isValid()) {
        if (role >= Qt::UserRole) {
            int columnIdx = role - Qt::UserRole - 1;
            QModelIndex modelIndex = this->index(index.row(), columnIdx);
            return QSqlTableModel::data(modelIndex, Qt::DisplayRole);
        }
    }

    return QSqlTableModel::data(index, role);
}

bool SqlTableModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (index.isValid()) {
        if (role >= Qt::UserRole) {
            int columnIdx = role - Qt::UserRole - 1;
            QModelIndex modelIndex = this->index(index.row(), columnIdx);
            return QSqlTableModel::setData(modelIndex, value, Qt::EditRole);
        }
    }

    return QSqlTableModel::setData(index, value, role);
}

void SqlTableModel::remove(int row)
{
    removeRow(row);
}

void SqlTableModel::update(GameData* game)
{
    if(!game)
        return;

    QString queryString = "UPDATE games SET "
                          "title = :title, "
                          "platform = :platform, "
                          "publisher = :publisher, "
                          "developer = :developer, "
                          "code = :code, "
                          "info = :info, "
                          "owned = :owned "
                          "WHERE tag = :tag";

    QSqlQuery query;
    query.prepare(queryString);
    query.bindValue(":title", game->title);
    query.bindValue(":platform", game->platform);
    query.bindValue(":publisher", game->publisher);
    query.bindValue(":developer", game->developer);
    query.bindValue(":code", game->code);
    query.bindValue(":info", game->info);
    query.bindValue(":owned", game->owned);
    query.bindValue(":tag", game->tag);

    query.exec();

    setQuery("SELECT * FROM games");
}

void SqlTableModel::insert(GameData* game)
{
    if(!game)
        return;

    QString queryString = "INSERT INTO games VALUES ("
                          "tag = :tag, "
                          "title = :title, "
                          "platform = :platform, "
                          "publisher = :publisher, "
                          "developer = :developer, "
                          "code = :code, "
                          "info = :info, "
                          "owned = :owned)";

    QSqlQuery query;
    query.prepare(queryString);
    query.bindValue(":tag", game->tag);
    query.bindValue(":title", game->title);
    query.bindValue(":platform", game->platform);
    query.bindValue(":publisher", game->publisher);
    query.bindValue(":developer", game->developer);
    query.bindValue(":code", game->code);
    query.bindValue(":info", game->info);
    query.bindValue(":owned", game->owned);

    query.exec();

    setQuery("SELECT * FROM games");
}

int SqlTableModel::getIndexFiltered(const QString& tag)
{
    auto list = match(index(0, 0), Qt::UserRole + 1, tag);
    if(!list.isEmpty()) {
        return list.first().row();
    }

    return -1;
}

int SqlTableModel::getIndexNotFiltered(const QString &tag)
{
//    auto savedFilter = filter();
//    setFilter("");
//    int idx = getIndexFiltered(tag);
//    setFilter(savedFilter);

    return 0;
}


void SqlTableModel::saveDBToFile(FileManager* fileManager)
{
    if(!fileManager) {
        return;
    }
    for(int r = 0; r < rowCount(); r++) {
        QVariantList list;
        for(int c = 0; c < columnCount(); c++) {
            list.append(data(index(r, c), 0));
        }
        auto game = GameDataMaker::get()->createComplete(list);
        fileManager->addEntry(game);
    }
}

void SqlTableModel::clearDB()
{
//    QSqlQuery query;
//    query.exec(QString("DELETE FROM %1").arg(tableName()));
    //    select();
}

void SqlTableModel::sort(int column, Qt::SortOrder order)
{
    qDebug() << "sort";
}

bool SqlTableModel::writeDataToDB(const QString &tag, int column, const QVariant &value)
{
    auto colName = m_roles[column + Qt::UserRole + 1];
    qDebug() << tag << colName;

//    QSqlQuery query;
//    query.prepare(QString("UPDATE games SET %1 = :valeur WHERE tag = :tag").arg(colName));
//    query.bindValue(":valeur", value);
//    query.bindValue(":tag", tag);
//    if (!query.exec()) {
//        qDebug() << "Erreur lors de l'exécution de la requête SQL:" << query.lastError().text();
//        return false;
//    }
    return true;
}





