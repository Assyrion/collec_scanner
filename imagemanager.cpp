#include <QCoreApplication>
#include <QDir>

#include "imagemanager.h"

ImageManager::ImageManager(QObject *parent) : QObject(parent)
{

}

QString ImageManager::getFrontPicGrab(const QString &tag)
{
    return getPicGrab(QString("%1_front.png").arg(tag));
}

QString ImageManager::getBackPicGrab(const QString& tag)
{
    return getPicGrab(QString("%1_back.png").arg(tag));
}

QString ImageManager::getPicGrab(const QString& fileName)
{
#ifdef Q_OS_ANDROID
    QString path = QDir::currentPath() + QDir::separator() + fileName; // can't use PICPATH_ABS, seems file:///./ does not work
#else
    QString path = PICPATH_ABS + QDir::separator() + fileName;
#endif
    if(QFile::exists(path)) {
        return QString("file:///%1").arg(path);
    }
    return "qrc:/no_pic";
}

void ImageManager::saveFrontPicGrab(const QString& tag, QQuickItemGrabResult* result)
{
    savePicGrab(QString("%1_front.png").arg(tag), result);
}

void ImageManager::saveBackPicGrab(const QString& tag, QQuickItemGrabResult* result)
{
    savePicGrab(QString("%1_back.png").arg(tag), result);
}

void ImageManager::savePicGrab(const QString& fileName, QQuickItemGrabResult* result)
{
#ifdef Q_OS_ANDROID
    QString path = QDir::currentPath() + QDir::separator() + fileName; // can't use PICPATH_ABS, seems file:///./ does not work
#else
    QString path = PICPATH_ABS + QDir::separator() + fileName;
#endif
    if(result) {
        result->saveToFile(path);
    }
}
