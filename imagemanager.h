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

    Q_INVOKABLE QString getFrontPicGrab(const QString& tag);
    Q_INVOKABLE QString getBackPicGrab( const QString& tag);
    Q_INVOKABLE void saveFrontPicGrab(  const QString& tag, QQuickItemGrabResult* result);
    Q_INVOKABLE void saveBackPicGrab(   const QString& tag, QQuickItemGrabResult* result);

private:
    void savePicGrab(  const QString& fileName, QQuickItemGrabResult* result);
    QString getPicGrab(const QString& fileName);

public slots:
};

#endif // IMAGEMANAGER_H
