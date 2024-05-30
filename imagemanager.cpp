#include <QCoreApplication>
#include <QDir>

#include "global.h"
#include "imagemanager.h"

ImageManager::ImageManager(QObject* parent)
    : QObject(parent)
{}

CoverProvider::CoverProvider(ImageManager* manager)
    : QQuickImageProvider(QQuickImageProvider::Image),
    m_coverManager(manager)
{}

QImage CoverProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    Q_UNUSED(size)
    Q_UNUSED(requestedSize)

    QString left  = id.split('.')[0];
    QString right = id.split('.')[1];

    if(right == "front") {
        return QImage(m_coverManager->getFrontPic(left));
    }

    if(right == "back") {
        return QImage(m_coverManager->getBackPic(left));
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
    QString path = Global::PICPATH_ABS + fileName;

    if(QFile::exists(path)) {
        return path;
    }
    return ":/no_pic";
}

void ImageManager::saveFrontPic(const QString& tag, const QImage& pic) const
{
    savePic(QString("%1_front.png").arg(tag), pic);
}

void ImageManager::saveBackPic(const QString& tag, const QImage& pic) const
{
    savePic(QString("%1_back.png").arg(tag), pic);
}

void ImageManager::savePic(const QString& fileName, const QImage& pic) const
{
    QImage pic_resized(pic);

#if QT_VERSION >= QT_VERSION_CHECK(6, 7, 0)
    float dpr = pic.devicePixelRatioF(); // devicePixelRatio is took in account when grabToImage from Qt6.7
    pic_resized = pic.scaled(pic.width()/dpr,
                             pic.height()/dpr);
#endif

    QString path = Global::PICPATH_ABS + fileName;
    if(!pic_resized.isNull()) {
        pic_resized.save(path);
    }
}

void ImageManager::removePics(const QString &tag) const
{
    removePic(QString("%1_front.png").arg(tag));
    removePic(QString("%1_back.png").arg(tag));
}

void ImageManager::removePic(const QString &fileName) const
{
    QString path = Global::PICPATH_ABS + fileName;
    QFile::remove(path);
}
