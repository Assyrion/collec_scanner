#include <QCoreApplication>

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
    QStringList pathList({DATAPATH, qApp->applicationName(), PICPATH, fileName});
    QString path = pathList.join('/');
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
    if(result) {
        QStringList path({DATAPATH, qApp->applicationName(), PICPATH, fileName});
        result->saveToFile(path.join('/'));
    }
}
