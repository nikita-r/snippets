/* sys.sql */

select * from sys.database_files;
dbcc sqlperf( logspace );

exec sp_who2;
exec sp_lock;

