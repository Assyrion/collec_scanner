#ifndef IMAGEMANAGER_H
#define IMAGEMANAGER_H

#include <QQuickImageProvider>
#include <QImage>
#include <QUrl>

class ImageManager : public QObject
{
    Q_OBJECT
public:
    explicit ImageManager(QObject *parent = nullptr);

    QString getFrontPic(const QString& tag) const;
    QString getBackPic( const QString& tag) const;

    Q_INVOKABLE void removePics(  const QString& tag) const;
    Q_INVOKABLE void saveFrontPic(const QString& tag, const QImage& pic) const;
    Q_INVOKABLE void saveBackPic( const QString& tag, const QImage& pic) const;

private:

    void savePic(  const QString& fileName, const QImage& pic) const;
    QString getPic(const QString& fileName) const;
    void removePic(const QString& fileName) const;

};

class CoverProvider : public QQuickImageProvider
{
public:
    explicit CoverProvider(ImageManager* manager);

    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize) Q_DECL_OVERRIDE;

private:
    ImageManager* m_coverManager;
};

#endif // IMAGEMANAGER_H
