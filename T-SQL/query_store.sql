/* query_store.sql */

-- Aborted in the past day

SELECT qsq.query_hash
     , qsqt.query_sql_text
     , qsrs.count_executions
     , qsrs.last_execution_time
     , Minimum = FORMAT(CONVERT(float, qsrs.min_duration) / 1000000, '#,0.000 sec')
     , Average = FORMAT(CONVERT(float, qsrs.avg_duration) / 1000000, '#,0.000 sec')
     , Maximum = FORMAT(CONVERT(float, qsrs.max_duration) / 1000000, '#,0.000 sec')
     , qpx.query_plan_xml
     , qsrs.execution_type
     , qsrs.execution_type_desc
  FROM sys.query_store_query qsq
  JOIN sys.query_store_query_text qsqt ON qsq.query_text_id = qsqt.query_text_id
  JOIN sys.query_store_plan qsp ON qsq.query_id = qsp.query_id
  OUTER APPLY (SELECT CONVERT(XML, qsp.query_plan) AS query_plan_xml) qpx
  JOIN sys.query_store_runtime_stats qsrs ON qsp.plan_id = qsrs.plan_id
 WHERE 1=1
   AND qsrs.execution_type = 3
   AND qsrs.last_execution_time > DATEADD(day, -1, convert(date, GETDATE()))
 ORDER BY qsrs.max_duration DESC;

