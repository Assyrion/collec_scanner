#ifndef IMAGEMANAGER_H
#define IMAGEMANAGER_H

#include <qquickimageprovider>
#include <QImage>
#include <QUrl>

class ImageManager : public QQuickImageProvider
{
public:
    explicit ImageManager();

//    Q_INVOKABLE void removePics(  const QString& tag) const;
    QString getFrontPic( const QString& tag) const;
    QString getBackPic(  const QString& tag) const;
//    Q_INVOKABLE void saveFrontPic(const QString& tag, const QImage& pic) const;
//    Q_INVOKABLE void saveBackPic( const QString& tag, const QImage& pic) const;

    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize) Q_DECL_OVERRIDE;

private:
    void savePic(  const QString& fileName, const QImage& pic) const;
    QString getPic(   const QString& fileName) const;
    void removePic(const QString& fileName) const;

public slots:
};

#endif // IMAGEMANAGER_H
