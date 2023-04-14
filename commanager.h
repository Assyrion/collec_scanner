#ifndef COMMANAGER_H
#define COMMANAGER_H

#include <QtGlobal>

#ifdef Q_OS_ANDROID

#include "private/qandroidextras_p.h"
#include <QFileInfoList>
#include <QObject>

class ComManager : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(ComManager)
public:
    explicit ComManager(QObject *parent = nullptr);

    void exportDB() const;

private:
    QFuture<QtAndroidPrivate::PermissionResult> m_permission;
};

#endif // COMMANAGER_H
#endif // Q_OS_ANDROID
