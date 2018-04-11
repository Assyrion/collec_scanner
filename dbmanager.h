#ifndef DBMANAGER_H
#define DBMANAGER_H

#include <QObject>
#include <QDebug>
#include <QSqlDatabase>
#include "sqltablemodel.h"

class GameData;
class SqlTableModel;
class DBManager : public QObject
{
    Q_OBJECT
public:
    explicit DBManager(QObject *parent = nullptr);

    Q_INVOKABLE void addEntry(GameData* game);
    Q_INVOKABLE void writeEntry(GameData* game);
    Q_INVOKABLE GameData* getEntry(QString tag);

private:
    SqlTableModel m_model;

//    const QString MyImageClasse::picture()
//    {
//       QImage myImage;
//      // Some init code to setup the image (e.g. loading a PGN/JPEG, etc.)
//      QByteArray bArray;
//      QBuffer buffer(&bArray);
//      buffer.open(QIODevice::WriteOnly);
//      myImage.save(&buffer, "JPEG");

//      QString image("data:image/jpg;base64,");
//      image.append(QString::fromLatin1(bArray.toBase64().data()));

//      return image;
//    }
};

#endif // DBMANAGER_H
