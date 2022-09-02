/* sys.sql */

/* Storage */
select * from sys.database_files;
dbcc sqlperf( logspace );

/* Sessions */
select connect_time, client_net_address--, program_name
       , hostname, loginame, auth_scheme, encrypt_option
       , last_write, num_writes, last_read, num_reads
  from sys.dm_exec_connections
  left join sys.sysprocesses ON spid = session_id
 order by connect_time desc, session_id asc;

/* my_who */
SELECT login_time, spid, last_batch, [status], loginame, hostname, program_name, cmd
  FROM sys.sysprocesses
 -- WHERE hostname = ''
 ORDER BY login_time aSC, spid aSC;

exec sp_who2;
exec sp_lock;

/* Navigate Data */
SELECT name FROM sys.databases;
use DB;
SELECT '['+TABLE_CATALOG+'].['+TABLE_SCHEMA+'].['+TABLE_NAME+']' as QualName FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE';

/* RBAC */
SELECT DP1.name as DatabaseRoleName,
       ISNULL( DP2.name, '<None>' ) as DatabaseUserName
  FROM sys.database_role_members AS DRM
       RIGHT OUTER JOIN sys.database_principals AS DP1
       ON DRM.role_principal_id = DP1.principal_id
       LEFT OUTER JOIN sys.database_principals AS DP2
       ON DRM.member_principal_id = DP2.principal_id
 WHERE DP1.type='R'
 ORDER BY DatabaseRoleName, DatabaseUserName;

/* Permissions */
SELECT o.type_desc as ObjectType
     , s.name as [Schema]
     , o.name as [Object]
     , permissions.state_desc as [Status]
     , permissions.permission_name as Permission
     , ee_principal.name as Principal
     , permissions.state as PermissionState
     , or_principal.name as GrantedBy
  FROM sys.objects o
  JOIN sys.schemas s ON o.schema_id = s.schema_id
  JOIN sys.database_permissions permissions ON o.object_id = permissions.major_id
  JOIN sys.database_principals ee_principal ON permissions.grantee_principal_id = ee_principal.principal_id
  JOIN sys.database_principals or_principal ON permissions.grantor_principal_id = or_principal.principal_id
 WHERE 1=1
 --AND permissions.type = 'EX'
 ORDER BY [Schema], [Object], ObjectType, Principal, Permission, [Status], GrantedBy
;

