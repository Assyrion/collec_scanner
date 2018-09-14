#ifndef IMAGEMANAGER_H
#define IMAGEMANAGER_H

#include <QObject>
#include <QQuickItem>
#include <QQuickItemGrabResult>

#include "global.h"

class ImageManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString path READ path WRITE setPath NOTIFY pathChanged)

public:
    explicit ImageManager(QObject *parent = nullptr);

    Q_INVOKABLE void removePics(    const QString& tag) const;
    Q_INVOKABLE QString getFrontPic(const QString& tag) const;
    Q_INVOKABLE QString getBackPic( const QString& tag) const;
    Q_INVOKABLE void saveFrontPic(  const QString& tag, QQuickItemGrabResult* result) const;
    Q_INVOKABLE void saveBackPic(   const QString& tag, QQuickItemGrabResult* result) const;

    QString path() const;
    void setPath(const QString &path);

private:
    void savePic(  const QString& fileName, QQuickItemGrabResult* result) const;
    QString getPic(const QString& fileName) const;
    void removePic(const QString& fileName) const;

    QString m_path;

signals:
    void pathChanged();
};

#endif // IMAGEMANAGER_H
