#ifndef GLOBAL_H
#define GLOBAL_H

#include <QStandardPaths>
#include <QDir>

const QString DBNAME  = "games.db";
const QString PICPATH = "pic/"; // pic

const QString REMOTE_PATH = "http://192.168.0.23/";
const QString REMOTE_PIC_PATH = REMOTE_PATH + PICPATH;

#ifdef Q_OS_ANDROID
const QString DATAPATH = ".";
const QString PICPATH_ABS = DATAPATH + QDir::separator()
        + PICPATH;
const QString DB_PATH_ABS_NAME = DATAPATH + QDir::separator()
        + DBNAME;
#else
const QString DATAPATH = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation);
const QString PICPATH_ABS = DATAPATH + QDir::separator()
        + QString(APPNAME) + QDir::separator()
        + PICPATH;
const QString DB_PATH_ABS_NAME = DATAPATH + QDir::separator()
        + QString(APPNAME) + QDir::separator()
        + DBNAME;
#endif

#endif // GLOBAL_H
