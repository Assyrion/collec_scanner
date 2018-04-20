#include <QCoreApplication>
#include <QDir>

#include "imagemanager.h"

ImageManager::ImageManager(QObject *parent)
    : QObject(parent)
{}

QString ImageManager::getFrontPic(const QString &tag)
{
    return getPic(QString("%1_front.png").arg(tag));
}

QString ImageManager::getBackPic(const QString& tag)
{
    return getPic(QString("%1_back.png").arg(tag));
}

QString ImageManager::getPic(const QString& fileName)
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

void ImageManager::saveFrontPic(const QString& tag, QQuickItemGrabResult* result)
{
    savePic(QString("%1_front.png").arg(tag), result);
}

void ImageManager::saveBackPic(const QString& tag, QQuickItemGrabResult* result)
{
    savePic(QString("%1_back.png").arg(tag), result);
}

void ImageManager::savePic(const QString& fileName, QQuickItemGrabResult* result)
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

void ImageManager::removePics(const QString &tag)
{
    removePic(QString("%1_front.png").arg(tag));
    removePic(QString("%1_back.png").arg(tag));
}

void ImageManager::removePic(const QString &fileName)
{
#ifdef Q_OS_ANDROID
    QString path = QDir::currentPath() + QDir::separator() + fileName; // can't use PICPATH_ABS, seems file:///./ does not work
#else
    QString path = PICPATH_ABS + QDir::separator() + fileName;
#endif
    QFile::remove(path);
}
