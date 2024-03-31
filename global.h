#ifndef GLOBAL_H
#define GLOBAL_H

#include <QStandardPaths>
#include <QDir>

#ifndef APPNAME
#include "cmake_global.h"
#endif

struct Global {
    inline static QString DBNAME = "games_ps3_complete.db"; // default DB
    inline static const QString PICPATH = "pic"; // pic

    inline static const QString REMOTE_PATH = "http://82.64.232.235/";
    inline static const QString REMOTE_PIC_PATH = REMOTE_PATH + PICPATH + "/";
    inline static const QString REMOTE_DB_PATH = REMOTE_PATH + "db/";
    inline static const QString REMOTE_UPLOAD_PIC_SCRIPT = REMOTE_PATH + "upload_cover_platform.php";
    inline static const QString REMOTE_UPLOAD_DB_SCRIPT = REMOTE_PATH + "upload_db.php";

    inline static const int DEFAULT_VIEW = 0;
    inline static const int DEFAULT_WINDOW_X = 50;
    inline static const int DEFAULT_WINDOW_Y = 50;
    inline static const int DEFAULT_WINDOW_W = 512;
    inline static const int DEFAULT_WINDOW_H = 773;
    inline static const QString DEFAULT_PLATFORM_NAME = "ps3";
    inline static const QStringList DEFAULT_SELECTED_PLATFORM = {"ps2", "ps3", "ps4", "ps5"};

#ifdef Q_OS_ANDROID
    inline static const QString DATAPATH = ".";
    inline static const QString PICPATH_ABS = DATAPATH + "/" + PICPATH + "/";
    inline static QString DB_PATH_ABS_NAME = DATAPATH + "/" + DBNAME;
#else
    inline static const QString DATAPATH = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation) + "/" + QString(APPNAME);
    inline static const QString PICPATH_ABS = DATAPATH + "/" + PICPATH + "/";
    inline static QString DB_PATH_ABS_NAME = DATAPATH + "/" + DBNAME;
#endif

    static void setDBName(const QString& newName) {
        DBNAME = newName;
        updateDBPathAbsName();
    }

private:

    static void updateDBPathAbsName() {
        DB_PATH_ABS_NAME = DATAPATH + "/" + DBNAME;
    }
};

#endif // GLOBAL_H
