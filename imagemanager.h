#ifndef IMAGEMANAGER_H
#define IMAGEMANAGER_H

#include <QObject>
#include <QImage>
#include <QUrl>

class ImageManager : public QObject
{
    Q_OBJECT

public:
    explicit ImageManager(QObject *parent = nullptr);

    Q_INVOKABLE void removePics(  const QString& tag) const;
    Q_INVOKABLE QUrl getFrontPic( const QString& tag) const;
    Q_INVOKABLE QUrl getBackPic(  const QString& tag) const;
    Q_INVOKABLE void saveFrontPic(const QString& tag, const QImage& pic) const;
    Q_INVOKABLE void saveBackPic( const QString& tag, const QImage& pic) const;

private:
    void savePic(  const QString& fileName, const QImage& pic) const;
    QUrl getPic(   const QString& fileName) const;
    void removePic(const QString& fileName) const;

public slots:
};

#endif // IMAGEMANAGER_H
