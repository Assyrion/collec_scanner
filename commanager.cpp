#include "commanager.h"

#ifdef Q_OS_ANDROID

#include "global.h"

#include <QFile>
#include <QDir>
#include <QFile>
#include <QDebug>
#include <QSaveFile>
#include <QStandardPaths>

ComManager::ComManager(QObject *parent) : QObject(parent)
{

    m_permission = QtAndroidPrivate::checkPermission(QString("android.permission.WRITE_EXTERNAL_STORAGE"));
    if(m_permission.result() != QtAndroidPrivate::PermissionResult::Authorized){
        m_permission = QtAndroidPrivate::requestPermission("android.permission.WRITE_EXTERNAL_STORAGE");
    }
}

void ComManager::exportDB() const
{
    // ask permission dynamically is required

    if(m_permission.result() != QtAndroidPrivate::PermissionResult::Authorized)
        return;

    // Due to QTBUG-64103 since Qt5.10, direct file copy is not possible, so we need to copy file content

    // Export DB to Download path
    QDir dirCur = QDir::current();
    QString downloadPath = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
    auto dbL = dirCur.entryInfoList({DBNAME}, QDir::Files);
    for(const auto &fileinfo: dbL) {
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
}

#endif
