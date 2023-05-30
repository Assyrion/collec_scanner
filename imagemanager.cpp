#include <QCoreApplication>
#include <QDir>

#include "global.h"
#include "imagemanager.h"

ImageManager::ImageManager()
    : QQuickImageProvider(QQuickImageProvider::Image)
{}

QImage ImageManager::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    Q_UNUSED(size)
    Q_UNUSED(requestedSize)

    QString left  = id.split('.')[0];
    QString right = id.split('.')[1];

    if(right == "front") {
        return QImage(getFrontPic(left));
    }

    if(right == "back") {
        return QImage(getBackPic(left));
    }

    return QImage(":/no_pic");
}

QString ImageManager::getFrontPic(const QString &tag) const
{
    return getPic(QString("%1_front.png").arg(tag));
}

QString ImageManager::getBackPic(const QString& tag) const
{
    return getPic(QString("%1_back.png").arg(tag));
}

QString ImageManager::getPic(const QString& fileName) const
{
#ifdef Q_OS_ANDROID
    const auto sep = QDir::separator();
    QString path = QDir::currentPath()
            + sep + PICPATH + fileName; // can't use PICPATH_ABS, seems file:///./ does not work
#else
    QString path = PICPATH_ABS + fileName;
#endif
    if(QFile::exists(path)) {
        return path;
    }
    return ":/no_pic";
}

//void ImageManager::saveFrontPic(const QString& tag, const QImage& pic) const
//{
//    savePic(QString("%1_front.png").arg(tag), pic);
//}

//void ImageManager::saveBackPic(const QString& tag, const QImage& pic) const
//{
//    savePic(QString("%1_back.png").arg(tag), pic);
//}

void ImageManager::savePic(const QString& fileName, const QImage& pic) const
{
#ifdef Q_OS_ANDROID
    const auto sep = QDir::separator();
    QString path = QDir::currentPath()
            + sep + PICPATH
            + sep + fileName; // can't use PICPATH_ABS, seems file:///./ does not work
#else
    QString path = PICPATH_ABS
            + '/' + fileName;
#endif
    if(!pic.isNull()) {
        pic.save(path);
    }
}

//void ImageManager::removePics(const QString &tag) const
//{
//    removePic(QString("%1_front.png").arg(tag));
//    removePic(QString("%1_back.png").arg(tag));
//}

void ImageManager::removePic(const QString &fileName) const
{
    const auto sep = QDir::separator();
#ifdef Q_OS_ANDROID
    QString path = QDir::currentPath()
            + sep + PICPATH
            + sep + fileName; // can't use PICPATH_ABS, seems file:///./ does not work
#else
    QString path = PICPATH_ABS
            + sep + fileName;
#endif
    QFile::remove(path);
}
