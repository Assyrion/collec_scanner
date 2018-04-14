#ifndef IMAGEMANAGER_H
#define IMAGEMANAGER_H

#include <QObject>
#include <QQuickItem>
#include <QQuickItemGrabResult>

#include "global.h"

class ImageManager : public QObject
{
    Q_OBJECT

public:
    explicit ImageManager(QObject *parent = nullptr);

    Q_INVOKABLE void removePics(    const QString& tag);
    Q_INVOKABLE QString getFrontPic(const QString& tag);
    Q_INVOKABLE QString getBackPic( const QString& tag);
    Q_INVOKABLE void saveFrontPic(  const QString& tag, QQuickItemGrabResult* result);
    Q_INVOKABLE void saveBackPic(   const QString& tag, QQuickItemGrabResult* result);

private:
    void savePic(  const QString& fileName, QQuickItemGrabResult* result);
    QString getPic(const QString& fileName);
    void removePic(const QString& fileName);

public slots:
};

#endif // IMAGEMANAGER_H
