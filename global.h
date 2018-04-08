#ifndef GLOBAL_H
#define GLOBAL_H

#include <QStandardPaths>

const QString DBNAME  = "games.db";
const QString PICPATH = "pic";

#ifdef Q_OS_ANDROID
const QString DATAPATH = "/storage/E0FD-1813/CollecScanner";
#else
const QString DATAPATH = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation);
#endif

#endif // GLOBAL_H
