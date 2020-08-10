#include "commanager.h"

#include <QFile>
#include <QDir>
#include <QFile>
#include <QDebug>
#include <QSaveFile>
#include <QStandardPaths>

#include "global.h"

#ifdef Q_OS_ANDROID
#include <QtAndroid>
#endif

ComManager::ComManager(QObject *parent) : QObject(parent)
{

}
void ComManager::exportDB() const
{
#ifdef Q_OS_ANDROID

    // ask permission dynamically is required
    auto  result = QtAndroid::checkPermission(QString("android.permission.WRITE_EXTERNAL_STORAGE"));
    if(result == QtAndroid::PermissionResult::Denied){
        QtAndroid::PermissionResultMap resultHash = QtAndroid::requestPermissionsSync(QStringList({"android.permission.WRITE_EXTERNAL_STORAGE"}));
        if(resultHash["android.permission.WRITE_EXTERNAL_STORAGE"] == QtAndroid::PermissionResult::Denied)
            return;
    }

    // Due to QTBUG-64103 since Qt5.10, direct file copy is not possible, so we need to copy file content

    // Export DB to Download path
    QDir dirCur = QDir::current();
    QString downloadPath = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
    auto dbL = dirCur.entryInfoList({DBNAME}, QDir::Files);
    for(auto fileinfo: dbL) {
        QFile from_dbf(fileinfo.absoluteFilePath());
        from_dbf.open(QIODevice::ReadOnly);
        QString toPath = downloadPath
                + QDir::separator()
                + fileinfo.fileName();
        QSaveFile to_dbf(toPath);
        to_dbf.open(QIODevice::WriteOnly);
        to_dbf.write(from_dbf.readAll());
        to_dbf.commit();
        to_dbf.setPermissions(QFile::WriteOwner | QFile::ReadOwner);
        from_dbf.close();
    }

    // Export pics to download path
    QDir picPath( downloadPath
                  + QDir::separator()
                  + PICPATH);
    if(!picPath.exists()) {
        picPath.mkpath(".");
    }

    dirCur.cd(PICPATH);
    auto pngL = dirCur.entryInfoList({"*.png"}, QDir::Files);
    for(auto fileinfo: pngL) {
        QFile from_pic(fileinfo.absoluteFilePath());
        from_pic.open(QIODevice::ReadOnly);
        QString toPath = picPath.absolutePath()
                + QDir::separator()
                + fileinfo.fileName();
        QSaveFile to_pic(toPath);
        to_pic.open(QIODevice::WriteOnly);
        to_pic.write(from_pic.readAll());
        to_pic.commit();
        to_pic.setPermissions(QFile::WriteOwner | QFile::ReadOwner);
        from_pic.close();
    }
#endif
}
