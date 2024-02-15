
import pyodbc

# Microsoft Access Database
odbc_cnxn_fstr = 'DRIVER={Microsoft Access Driver (*.mdb)};DBQ=%s;READONLY=True'
cnxn = pyodbc.connect(odbc_cnxn_fstr % mdb_filepath)
#cnxn.setdecoding(pyodbc.SQL_WCHAR, 'cp1252')
#cnxn.setdecoding(pyodbc.SQL_WMETADATA, 'cp1252')
#cnxn.setencoding(encoding='utf-8')
cursor = cnxn.cursor()
for t in cursor.tables(): print(t.table_name)
...
for c in cursor.columns(table=''):
    print(f'[{c.ordinal_position:02d}] {c.column_name}: {c.type_name}')
...
for t in tuple(cursor.tables()):
    if t.table_name.startswith('MSys'): continue
    _ = cursor.execute('SELECT count(*) FROM [%s]' % t.table_name)
    print(f'{t.table_name} | rowcount={cursor.fetchone()[0]}')
...
sql = 'SELECT %s FROM %s ORDER BY %s' % ()
try:
    cursor.execute(sql)
except pyodbc.ProgrammingError:
    print('Failed Query: %s' % sql, file=sys.stderr)
    raise
while (row := cursor.fetchone()):
    ...

cursor.description # schema of a row

# SQL Server
#;UID=username;PWD=password
cnxn = pyodbc.connect(driver='{SQL Server}', Trusted_Connection='Yes', server='', database='', readonly=True)
cursor = cnxn.cursor()

for t in cursor.tables():
    if t.table_schem == 'dbo' and t.table_type == 'TABLE':
        print(t.table_name)

for t in cursor.tables():
    if t.table_schem == 'dbo' and t.table_type == 'VIEW':
        print(t.table_name)

# Locate non-ASCII in NText
sql = 'SELECT %s FROM %s WHERE 1=1 AND ( %s ) ORDER BY %s' % (
    'ArticleId',
    'Article',
    'PlainText collate Latin1_General_BIN != cast(PlainText as varchar(max))',
    'ArticleId deSC')
cursor.execute(sql)
while (row := cursor.fetchone()):
    print(row.ArticleId)


