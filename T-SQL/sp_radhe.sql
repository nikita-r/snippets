/* sp_radhe.sql */

--# make it system-stored
--> exec sys.sp_MS_marksystemobject 'sp_radhe'

USE [master]
go

CREATE PROCEDURE [dbo].[sp_radhe]

AS
begin

set transaction isolation level read uncommitted

SELECT es.session_id AS session_id
     , COALESCE( es.original_login_name, '' ) AS login_name
     , es.login_time
     , COALESCE( es.host_name, '' ) AS hostname

     , COALESCE( es.program_name, '' ) AS program_name
     , COALESCE( er.open_transaction_count, -1 ) AS open_trans

     , es.status
     , COALESCE( es.last_request_end_time, es.last_request_start_time ) AS req_time
     , COALESCE( er.blocking_session_id, 0 ) AS blocked_by

     , coalesce( db_name(er.database_id), '???' ) as db_id
     , COALESCE( er.command, 'awaiting command' ) AS cmd

     , transaction_isolation = CASE es.transaction_isolation_level
                                    WHEN 0 THEN 'Unspecified'
                                    WHEN 1 THEN 'Read Uncommitted'
                                    WHEN 2 THEN 'Read Committed'
                                    WHEN 3 THEN 'Repeatable'
                                    WHEN 4 THEN 'Serializable'
                                    WHEN 5 THEN 'Snapshot'
                                           ELSE '???'
                                END

     , COALESCE( er.wait_type, '?' ) AS wait_type
     , COALESCE( er.wait_time, 0 ) AS wait_time
     , COALESCE( er.last_wait_type, '?' ) AS last_wait_type
     , COALESCE( er.wait_resource, '' ) AS wait_resource

     , COALESCE( es.cpu_time, 0 )
     + COALESCE( er.cpu_time, 0 ) AS cpu_time

     , COALESCE( es.reads, 0 )
     + COALESCE( es.writes, 0 )
     + COALESCE( er.reads, 0 )
     + COALESCE( er.writes, 0 ) AS physical_io

  FROM
      sys.dm_exec_sessions es
  LEFT OUTER JOIN
      sys.dm_exec_requests er ON es.session_id = er.session_id
  LEFT OUTER JOIN
      sys.dm_os_tasks ta ON es.session_id = ta.session_id
  LEFT OUTER JOIN
      sys.dm_os_threads th ON ta.worker_address = th.worker_address

 WHERE es.is_user_process = 1
   and es.session_id <> @@spid
   and es.status = 'running'

 ORDER BY es.session_id

end

GO
