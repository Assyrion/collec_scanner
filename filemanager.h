#ifndef FILEMANAGER_H
#define FILEMANAGER_H

#include <QObject>
#include <QFile>

struct JV {
    QString id;
    QString title;
};

class FileManager : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(FileManager)
public:
    explicit FileManager(QObject *parent = nullptr);
    ~FileManager();

    Q_INVOKABLE bool checkEntry(QString id);
    Q_INVOKABLE void addEntry(QString id, QString title);
    Q_INVOKABLE QString getEntry(QString id);

private:
    QFile m_jvFile;

signals:

};

#endif // FILEMANAGER_H
