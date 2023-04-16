
#ifndef COVERMANAGER_H
#define COVERMANAGER_H


#include <QObject>


class CoverManager : public QObject
{
    Q_OBJECT
public:
    explicit CoverManager(QObject *parent = nullptr);

    Q_INVOKABLE void uploadCovers();
    Q_INVOKABLE void downloadCovers(QObject* dialog);

signals:

};

#endif // COVERMANAGER_H
