#ifndef COMMANAGER_H
#define COMMANAGER_H

#include <QObject>

class ComManager : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(ComManager)
public:
    explicit ComManager(QObject *parent = nullptr);

    Q_INVOKABLE void exportDB() const;
};

#endif // COMMANAGER_H
