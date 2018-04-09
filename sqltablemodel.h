#ifndef SQLTABLEMODEL_H
#define SQLTABLEMODEL_H
#include <QSqlTableModel>

class SqlTableModel : public QSqlTableModel
{
public:
    SqlTableModel();
    ~SqlTableModel() Q_DECL_OVERRIDE;
};

#endif // SQLTABLEMODEL_H
