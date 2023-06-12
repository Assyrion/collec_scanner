#ifndef GLOBAL_H
#define GLOBAL_H

#include <QStandardPaths>
#include <QDir>

struct Global {
    inline static QString DBNAME = "games_ps3_complete.db"; // default DB
    inline static const QString PICPATH = "pic"; // pic

    inline static const QString REMOTE_PATH = "http://collecscanner.freeboxos.fr/";
    inline static const QString REMOTE_PIC_PATH = REMOTE_PATH + PICPATH + "/";
    inline static const QString REMOTE_DB_PATH = REMOTE_PATH + "db/";
    inline static const QString REMOTE_UPLOAD_PIC_SCRIPT = REMOTE_PATH + "upload_cover_platform.php";
    inline static const QString REMOTE_UPLOAD_DB_SCRIPT = REMOTE_PATH + "upload_db.php";

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
