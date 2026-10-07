
-- |------------------------------------------------------------------------------------|
-- |                           DB_MySQL_HC By IT邦德                                       |
-- |------------------------------------------------------------------------------------|
-- | DATABASE : MySQL                                                                   |
-- | AUTHOR   : jeames 公众号：IT邦德
-- | FILE     : DB_MySQL_HC.sql                                                         |
-- | CLASS    : Database Administration                                                 |
-- | PURPOSE  : This SQL script provides a detailed report (in HTML format)             |
-- | VERSION  : This script was designed for MySQL Database 8.0、5.6、5.7               |
-- | NOTE     : AS with any code, ensure to test this script in a development           |
-- |            environment before attempting to run it in production.                  |
-- +------------------------------------------------------------------------------------+

/* 脚本运行方式： 
/* mysql -uroot -proot -h192.168.3.10 -P3306 -S/tmp/mysql.sock -f --silent < DB_MySQL_HC_BOE.sql > boe_mysql_check.html */
/* mysql -uroot -proot -S/tmp/mysql80.sock  -s -f <  DB_MySQL_HC_lhr_v7.0.0.sql  > boe_mysql_check.html  */
/*
远程用户创建
CREATE USER 'root'@'%' IDENTIFIED BY 'root';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
*/
/* set @dt=(SELECT DATE_FORMAT(now(),'%Y%m%d%H%i%s') dt); */


select  '<html lang="en"><head><title>MySQL Report</title> <style type="text/css">';
select  'body.awr {font:bold 10pt Consolas;color:black;background:White;}';
select  'table  {font:11px Consolas; color:Black; background:#FFFFCC; padding:1px; margin:0px 0px 0px 0px; cellspacing:0px;border-collapse:collapse;}';
select  'th  {font:bold 11px Consolas; color:White; background:#0066cc; padding:5px; cellspacing:0px;border-collapse:collapse;white-space: nowrap;}';
select  'td {font-family:Consolas; word-wrap: break-word; white-space: pre-wrap; }';
select  'tr:nth-child(odd){background:White;}';
select  'tr:hover   {background-color: yellow;}';
select  'th.awrbg   {font:bold 10pt Consolas; color:White; background:#0066CC;padding-left:0px; padding-right:0px;padding-bottom:0px}';
select  'th.awrnc   {font:9pt Consolas;color:black;background:White;}';
select  'th.awrc    {font:9pt Consolas;color:black;background:#FFFFCC;}';
select  'td.awrnc   {font:9pt Consolas;color:black;background:White;vertical-align:middle;padding:4;}';
select  'a.info:hover {background:#eee;color:#000000; position:relative;}';
select  'a.info span {display: none; }';
select  'a.info:hover span {font-size:11px!important; color:#000000; display:block;position:absolute;top:30px;left:40px;width:150px;border:1px solid #ff0000; background:#FFFF00; padding:1px 1px;text-align:left;word-wrap: break-word; white-space: pre-wrap;}';
select  'td.awrc    {font:9pt Consolas;color:black;background:#FFFFCC; vertical-align:middle;padding:4;}</style></head>';
select  '<body class="awr">';

select  '<center><font size=+3 color=darkgreen><b>MySQL数据库巡检报告</b></font></center>';



-- +----------------------------------------------------------------------------+
-- +----------------------------------------------------------------------------+
-- |                             - REPORT HEADER -                              |
-- +----------------------------------------------------------------------------+


select  '<a name=top></a>';
select  '<hr>';
select  '<p>';
select  '<a style="font-weight:lighter">巡 检 人：IT邦德</a></br>';
select  concat('<a style="font-weight:lighter">巡检时间：',DATE_FORMAT(now(),'%Y-%m-%d %H:%i:%s'));
select  ' </a></br>';
select  '<a style="font-weight:lighter">版 本 号：v3.0.0</a></br>';

select  '<p>';
select  '[<a class="noLink" href="#html_bottom_link"  style="font-weight:lighter">转到页底</a>]';
select  '<hr>';

 

select  '<center><a name="directory"><font size=+2 face="Consolas" color="#336699"><b>巡检明细</b></font></a></center>';
select  '<hr>';

select  '<table width="100%" border="1" bordercolor="#000000" cellspacing="0px" style="border-collapse:collapse; margin-top:0.3cm;" align="center">';

select  '<tr>';
select  '<td style="background-color:#FFCC00" rowspan="2"  nowrap align="center" width="10%"><a class="info" href="#"><font size=+0.5 face="Consolas" color="#000000"><b>总体概况</b></font></a></td>';
select  '<td nowrap align="center" width="18%"  style="background-color:#FFFFCC" ><a class="info" href="#db_base_info"><font size=2.5 face="Consolas" color="#336699">数据库基本信息<span>数据库的总体概况、版本、主机情况、数据库负载情况、数据库属性等</span></font></a></td>';
select  '<td nowrap align="center" style="background-color:#FFFFCC" ><a class="info" href="#all_db_and_size"><font size=2.5 face="Consolas" color="#336699">数据库及其容量大小<span>当前数据库实例的所有数据库及其容量大小</span></font></a></td>';
select  '<td nowrap align="center" style="background-color:#FFFFCC" ><a class="info" href="#db_status"><font size=2.5 face="Consolas" color="#336699">数据库的运行状态</font></a></td>';
select  '<td nowrap align="center" style="background-color:#FFFFCC" ><a class="info" href="#top10_tb_size"><font size=2.5 face="Consolas" color="#336699">占用空间最大的前10张大表</font></a></td>';
select  '<td nowrap align="center" style="background-color:#FFFFCC" ><a class="info" href="#all_engines"><font size=2.5 face="Consolas" color="#336699">存储引擎列表<span>当前数据库实例的所有存储引擎列表</span></font></a></td>';
select  '</tr>'; 

select  '<tr>';
select  '<td nowrap align="center" style="background-color:#FFFFCC" ><a class="info" href="#engines_db"><font size=2.5 face="Consolas" color="#336699">存储引擎和DB的数量关系</font></a></td>';
select  '<td nowrap align="center" style="background-color:#FFFFCC" ><a class="info" href="#ALL_USES"><font size=2.5 face="Consolas" color="#336699">查询所有用户</font></a></td>';
select  '<td nowrap align="center" style="background-color:#FFFFCC" ><a class="info" href="#IMPORTANT_INIT"><font size=2.5 face="Consolas" color="#336699">重要的参数</font></a></td>';
select  '<td nowrap align="center" style="background-color:#FFFFCC" ><a class="info" href="#PARTITIONS_INFO"><font size=2.5 face="Consolas" color="#336699">分区表信息</font></a></td>';
select  '<td nowrap align="center" style="background-color:#FFFFCC" ><a class="info" href="#BIGDQL"><font size=2.5 face="Consolas" color="#336699">大查询监控</font></a></td>';
select  '</tr>';
select  '</table>';


select  '<br />';
select  '<hr>';
select  '<br />';



-- +----------------------------------------------------------------------------+
-- +----------------------------------------------------------------------------+
-- |                             - DATABASE OVERVIEW -                          |
-- +----------------------------------------------------------------------------+

select  '<a name="db_base_info"></a>';
select  '<p><font size="+1" face="Consolas" color="#336699"><b>● 数据库基本信息</b></font>';

SELECT '<table border=1><tr><th>now_date</th><th>user</th><th>CURRENT_USER1</th><th>CONNECTION_ID</th><th>Server_version</th><th>all_db_size_MB</th><th>all_datafile_size_MB</th><th>datadir</th><th>SOCKET</th><th>log_error</th><th>autocommit</th><th>log_bin</th><th>server_id</th></tr>'

UNION ALL 
SELECT concat('<tr><td>',now_date,'</td><td>',user,'</td><td>',CURRENT_USER1,'</td><td>',CONNECTION_ID,'</td><td>',Server_version,'</td><td>',ifnull(all_db_size_MB,''),'</td><td>',ifnull(all_datafile_size_MB,''),'</td><td>',datadir,'</td><td>',SOCKET,'</td><td>',log_error,'</td><td>',autocommit,'</td><td>',log_bin,'</td><td>',server_id,'</td></tr>') 
from (SELECT  now() now_date,
	USER() user, -- USER()、 SYSTEM_USER()、 SESSION_USER()、 
	CURRENT_USER() CURRENT_USER1,
	CONNECTION_ID() CONNECTION_ID,
	version() Server_version,
	( SELECT sum( TRUNCATE ( ( data_length + index_length ) / 1024 / 1024, 2 ) ) AS 'all_db_size(MB)' FROM information_schema.TABLES b ) all_db_size_MB,
	(select truncate(sum(total_extents*extent_size)/1024/1024,2) from  information_schema.FILES b) all_datafile_size_MB,
	( SELECT @@datadir ) datadir,
	( SELECT @@SOCKET ) SOCKET,
	( SELECT @@log_error ) log_error,
	-- ( SELECT @@tx_isolation ) tx_isolation, -- SELECT @@transaction_isolation tx_isolation
	( SELECT @@autocommit ) autocommit,
	( SELECT @@log_bin ) log_bin,
	( SELECT @@server_id ) server_id ) V

UNION ALL 
SELECT '</table>' ; 




select  '<p><font size="+1" face="Consolas" color="#336699"><b>● 版本信息</b></font>';

-- select  '</br><textarea style="width:600px;font-family:Consolas;font-size:11px;overflow:auto;background-color:#FFFFCC" -- rows="8">';
-- 
-- show variables like 'version_%';
-- 
-- select  '</textarea>';

SELECT '<table border=1><tr><th>VARIABLE_NAME</th><th>VARIABLE_VALUE</th></tr>'
UNION ALL
SELECT concat('<tr><td>',VARIABLE_NAME,'</td><td>',VARIABLE_VALUE,'</td></tr>') 
from (select * from performance_schema.global_variables where  VARIABLE_NAME like 'version_%') V
UNION ALL 
SELECT '</table>'
;

select  '<center>[<a class="noLink" href="#directory">回到目录</a>]</center><p></hr>';
select  '<hr><p><p>';


-- +----------------------------------------------------------------------------+
-- +----------------------------------------------------------------------------+
-- |                             - all_db_and_size  -                           |
-- +----------------------------------------------------------------------------+

select  '<a name="all_db_and_size"></a>';
select  '<p><font size="+1" face="Consolas" color="#336699"><b>● 数据库及其容量大小</b></font>';
-- show databases;
SELECT '<table border=1><tr><th>SCHEMA_NAME</th><th>DEFAULT_CHARACTER_SET_NAME</th><th>DEFAULT_COLLATION_NAME</th><th>table_rows</th><th>data_size_mb</th><th>index_size_mb</th><th>all_size_mb</th><th>max_size_mb</th><th>free_size_mb</th><th>disk_size_mb</th></tr>'

UNION ALL 
SELECT concat('<tr><td>',SCHEMA_NAME,'</td><td>',DEFAULT_CHARACTER_SET_NAME,'</td><td>',DEFAULT_COLLATION_NAME,'</td><td>',ifnull(table_rows,''),'</td><td>',ifnull(data_size_mb,''),'</td><td>',ifnull(index_size_mb,''),'</td><td>',ifnull(all_size_mb,''),'</td><td>',ifnull(max_size_mb,''),'</td><td>',ifnull(free_size_mb,''),'</td><td>',ifnull(disk_size_mb,''),'</td></tr>') 
from (select a.SCHEMA_NAME, a.DEFAULT_CHARACTER_SET_NAME,a.DEFAULT_COLLATION_NAME,
sum(table_rows) as table_rows,
truncate(sum(data_length)/1024/1024, 2) as data_size_mb,
truncate(sum(index_length)/1024/1024, 2) as index_size_mb,
truncate(sum(data_length+index_length)/1024/1024, 2) as all_size_mb,
truncate(sum(max_data_length)/1024/1024, 2) as max_size_mb,
truncate(sum(data_free)/1024/1024, 2) as free_size_mb,
max(f.filesize_M)  as disk_size_mb
from INFORMATION_SCHEMA.SCHEMATA a
left outer join information_schema.tables b
on a.SCHEMA_NAME=b.TABLE_SCHEMA
left outer join 
    (select substring(b.file_name,3,locate('/',b.file_name,3)-3) as db_name,
			truncate(sum(total_extents*extent_size)/1024/1024,2) filesize_M
			from  information_schema.FILES b 
			group by substring(b.file_name,3,locate('/',b.file_name,3)-3)) f
on ( a.SCHEMA_NAME= f.db_name)
group by a.SCHEMA_NAME,  a.DEFAULT_CHARACTER_SET_NAME,a.DEFAULT_COLLATION_NAME
order by sum(data_length) desc, sum(index_length) desc) V

UNION ALL 
SELECT '</table>'
;






select  '<a name="all_db_objects"></a>';
select  '<p><font size="+1" face="Consolas" color="#336699"><b>● 数据库对象</b></font>';


SELECT '<table border=1><tr><th>db_name</th><th>ob_type</th><th>sums</th></tr>'

UNION ALL 
SELECT concat('<tr><td>',db_name,'</td><td>',ob_type,'</td><td>',sums,'</td></tr>') from 
(select db as db_name ,type as ob_type,cnt as sums from 
(select 'TABLE' type,table_schema db, count(*) cnt  from information_schema.`TABLES` a where table_type='BASE TABLE' group by table_schema
union all
select 'EVENTS' type,event_schema db,count(*) cnt from information_schema.`EVENTS` b group by event_schema
union all
select 'TRIGGERS' type,trigger_schema db,count(*) cnt from information_schema.`TRIGGERS` c group by trigger_schema
union all
select 'PROCEDURE' type,routine_schema db,count(*) cnt from information_schema.ROUTINES d where`ROUTINE_TYPE` = 'PROCEDURE' group by db
union all
select 'FUNCTION' type,routine_schema db,count(*) cnt  from information_schema.ROUTINES d where`ROUTINE_TYPE` = 'FUNCTION' group by db
union all
select 'VIEWS' type,TABLE_SCHEMA db,count(*) cnt  from information_schema.VIEWS f group by table_schema  ) t
order by db,type) V

UNION ALL 
SELECT '</table>' ;


select  '<center>[<a class="noLink" href="#directory">回到目录</a>]</center><p></hr>';
select  '<hr><p><p>';


-- +----------------------------------------------------------------------------+
-- +----------------------------------------------------------------------------+
-- |                             - db_status  -                                 |
-- +----------------------------------------------------------------------------+

select  '<a name="db_status"></a>';
select  '<p><font size="+1" face="Consolas" color="#336699"><b>● 数据库的运行状态</b></font>';
select  '<TABLE BORDER=1><tr><td style="background:#FFFFCC;font-family:Consolas; word-wrap: break-word; white-space: pre-wrap; white-space: -moz-pre-wrap">';

status;


select  '</TD></TR></TABLE>';



select  '<center>[<a class="noLink" href="#directory">回到目录</a>]</center><p></hr>';
select  '<hr><p><p>';


-- +----------------------------------------------------------------------------+
-- +----------------------------------------------------------------------------+
-- |                             - top10_tb_size  -                             |
-- +----------------------------------------------------------------------------+

select  '<a name="top10_tb_size"></a>';
select  '<p><font size="+1" face="Consolas" color="#336699"><b>● 占用空间最大的前10张大表</b></font>';

/* 
1、表和索引在同一个文件中，例如sbtest6.ibd文件中包括了索引和数据
2、主键索引的大小就是数据大小
3、SQL查询出来的总大小应该减去datafree才是真实的占用空间
*/


 
SELECT '<table border=1><tr><th>db_name</th><th>table_name</th><th>TABLE_TYPE</th><th>ENGINE</th><th>CREATE_TIME</th><th>UPDATE_TIME</th><th>TABLE_COLLATION</th><th>table_rows</th><th>tb_size_mb</th><th>index_size_mb</th><th>all_size_mb</th><th>free_size_mb</th><th>disk_size_mb</th></tr>'

UNION ALL 
SELECT concat('<tr><td>',db_name,'</td><td>',table_name,'</td><td>',TABLE_TYPE,'</td><td>',ENGINE,'</td><td>',CREATE_TIME,'</td><td>',ifnull(UPDATE_TIME,''),'</td><td>',TABLE_COLLATION,'</td><td>',table_rows,'</td><td>',tb_size_mb,'</td><td>',index_size_mb,'</td><td>',all_size_mb,'</td><td>',free_size_mb,'</td><td>',ifnull(disk_size_mb,''),'</td></tr>') 
from (SELECT
	table_schema AS db_name,
	table_name AS table_name,
	a.TABLE_TYPE,
	a.`ENGINE`,
	a.CREATE_TIME,
	a.UPDATE_TIME,
	a.TABLE_COLLATION,
	table_rows AS table_rows,
	TRUNCATE(a.DATA_LENGTH / 1024 / 1024, 2 ) AS tb_size_mb,
	TRUNCATE( index_length / 1024 / 1024, 2 ) AS index_size_mb,
	TRUNCATE( ( data_length + index_length ) / 1024 / 1024, 2 ) AS all_size_mb,
  TRUNCATE( a.DATA_FREE / 1024 / 1024, 2 ) AS free_size_mb,
  truncate(f.filesize_M,2) AS disk_size_mb
FROM information_schema.TABLES a
left outer join 
    (select substring(b.file_name,3,locate('/',b.file_name,3)-3) as db_name,  
			substring(b.file_name,locate('/',b.file_name,3)+1,(LENGTH(b.file_name)-locate('/',b.file_name,3)-4)) as tb_name,
			b.file_name,
			(total_extents*extent_size)/1024/1024 filesize_M
			from  information_schema.FILES b 
			order by filesize_M desc limit 20 ) f
on ( a.TABLE_SCHEMA= f.db_name and a.TABLE_NAME=f.tb_name )
ORDER BY ( data_length + index_length ) DESC 
LIMIT 10) V

UNION ALL 
SELECT '</table>' 
;


select  '<a name="top10_tb_size"></a>';
select  '<p><font size="+1" face="Consolas" color="#336699"><b>● 占用空间最大的前10个索引</b></font>';


SELECT '<table border=1><tr><th>database_name</th><th>table_name</th><th>index_name</th><th>SizeMB</th><th>NON_UNIQUE</th><th>INDEX_TYPE</th><th>COLUMN_NAME</th></tr>'

UNION ALL 
SELECT concat('<tr><td>',database_name,'</td><td>',table_name,'</td><td>',index_name,'</td><td>',SizeMB,'</td><td>',NON_UNIQUE,'</td><td>',INDEX_TYPE,'</td><td>',COLUMN_NAME,'</td></tr>') from
(select 
iis.database_name, 
iis.table_name, 
iis.index_name, 
round((iis.stat_value*@@innodb_page_size)/1024/1024, 2) SizeMB, 
-- round(((100/(SELECT INDEX_LENGTH FROM INFORMATION_SCHEMA.TABLES t WHERE t.TABLE_NAME = iis.table_name and t.TABLE_SCHEMA = iis.database_name))*(stat_value*@@innodb_page_size)), 2) `Percentage`,
s.NON_UNIQUE,
s.INDEX_TYPE,
GROUP_CONCAT(s.COLUMN_NAME order by SEQ_IN_INDEX) COLUMN_NAME
from (select * from mysql.innodb_index_stats 
				WHERE index_name  not in ('PRIMARY','GEN_CLUST_INDEX') and stat_name='size' 
				order by (stat_value*@@innodb_page_size) desc limit 10
			) iis 
left join INFORMATION_SCHEMA.STATISTICS s
on (iis.database_name=s.TABLE_SCHEMA and iis.table_name=s.TABLE_NAME and iis.index_name=s.INDEX_NAME)
GROUP BY iis.database_name,iis.TABLE_NAME,iis.INDEX_NAME,(iis.stat_value*@@innodb_page_size),s.NON_UNIQUE,s.INDEX_TYPE
order by (stat_value*@@innodb_page_size) desc) V

UNION ALL 
SELECT '</table>' 
;

select  '<center>[<a class="noLink" href="#directory">回到目录</a>]</center><p></hr>';
select  '<hr><p><p>';


-- +----------------------------------------------------------------------------+
-- +----------------------------------------------------------------------------+
-- |                             - all_engines  -                               |
-- +----------------------------------------------------------------------------+

select  '<a name="all_engines"></a>';
select  '<p><font size="+1" face="Consolas" color="#336699"><b>● 存储引擎列表</b></font>';
-- show engines;
-- SELECT * from information_schema.`ENGINES`;
SELECT '<table border=1><tr><th>ENGINE</th><th>SUPPORT</th><th>COMMENT</th><th>TRANSACTIONS</th><th>XA</th><th>SAVEPOINTS</th></tr>'

UNION ALL 
SELECT concat('<tr><td>',ENGINE,'</td><td>',SUPPORT,'</td><td>',COMMENT,'</td><td>',ifnull(TRANSACTIONS,''),'</td><td>',ifnull(XA,''),'</td><td>',ifnull(SAVEPOINTS,''),'</td></tr>') 
from (SELECT * from information_schema.`ENGINES`) V

UNION ALL 
SELECT '</table>' 
;

select  '<center>[<a class="noLink" href="#directory">回到目录</a>]</center><p></hr>';
select  '<hr><p><p>';


-- +----------------------------------------------------------------------------+
-- +----------------------------------------------------------------------------+
-- |                             - engines_db  -                                |
-- +----------------------------------------------------------------------------+

select  '<a name="engines_db"></a>';
select  '<p><font size="+1" face="Consolas" color="#336699"><b>● 存储引擎和DB的数量关系 </b></font>';


SELECT '<table border=1><tr><th>ENGINE</th><th>counts</th></tr>'

UNION ALL 
SELECT concat('<tr><td>',ifnull(ENGINE,''),'</td><td>',counts,'</td></tr>') 
from (SELECT a.`ENGINE`,count( * ) counts 
FROM    information_schema.`TABLES` a 
GROUP BY a.`ENGINE`) V

UNION ALL 
SELECT '</table>' 
;


select  '<p>';
SELECT '<table border=1><tr><th>TABLE_SCHEMA</th><th>ENGINE</th><th>counts</th></tr>'

UNION ALL 
SELECT concat('<tr><td>',TABLE_SCHEMA,'</td><td>',ifnull(ENGINE,''),'</td><td>',counts,'</td></tr>') 
from (SELECT  a.TABLE_SCHEMA,
	a.`ENGINE`,
	count( * ) counts 
FROM    information_schema.`TABLES` a 
GROUP BY  a.TABLE_SCHEMA,a.`ENGINE` 
ORDER BY a.TABLE_SCHEMA) V

UNION ALL 
SELECT '</table>' 
;


select  '<a name="innodb_tablespaces"></a>';
select  '<p><font size="+1" face="Consolas" color="#336699"><b>● InnoDB 系统表空间</b></font>';
-- select * from information_schema.innodb_tablespaces where space_type<>'Single';
-- select  '<p>';


SELECT '<table border=1><tr><th>FILE_ID</th><th>FILE_NAME</th><th>FILE_TYPE</th><th>TABLESPACE_NAME</th><th>TABLE_CATALOG</th><th>TABLE_SCHEMA</th><th>TABLE_NAME</th><th>LOGFILE_GROUP_NAME</th><th>LOGFILE_GROUP_NUMBER</th><th>ENGINE</th><th>FULLTEXT_KEYS</th><th>DELETED_ROWS</th><th>UPDATE_COUNT</th><th>FREE_EXTENTS</th><th>TOTAL_EXTENTS</th><th>EXTENT_SIZE</th><th>INITIAL_SIZE</th><th>MAXIMUM_SIZE</th><th>AUTOEXTEND_SIZE</th><th>CREATION_TIME</th><th>LAST_UPDATE_TIME</th><th>LAST_ACCESS_TIME</th><th>RECOVER_TIME</th><th>TRANSACTION_COUNTER</th><th>VERSION</th><th>ROW_FORMAT</th><th>TABLE_ROWS</th><th>AVG_ROW_LENGTH</th><th>DATA_LENGTH</th><th>MAX_DATA_LENGTH</th><th>INDEX_LENGTH</th><th>DATA_FREE</th><th>CREATE_TIME</th><th>UPDATE_TIME</th><th>CHECK_TIME</th><th>CHECKSUM</th><th>STATUS</th><th>EXTRA</th></tr>'

UNION ALL 
SELECT concat('<tr><td>',FILE_ID,'</td><td>',FILE_NAME,'</td><td>',FILE_TYPE,'</td><td>',TABLESPACE_NAME,'</td><td>',TABLE_CATALOG,'</td><td>',ifnull(TABLE_SCHEMA,''),'</td><td>',ifnull(TABLE_NAME,''),'</td><td>',ifnull(LOGFILE_GROUP_NAME,''),'</td><td>',ifnull(LOGFILE_GROUP_NUMBER,''),'</td><td>',ENGINE,'</td><td>',ifnull(FULLTEXT_KEYS,''),'</td><td>',ifnull(DELETED_ROWS,''),'</td><td>',ifnull(UPDATE_COUNT,''),'</td><td>',FREE_EXTENTS,'</td><td>',TOTAL_EXTENTS,'</td><td>',EXTENT_SIZE,'</td><td>',ifnull(INITIAL_SIZE,''),'</td><td>',ifnull(MAXIMUM_SIZE,''),'</td><td>',ifnull(AUTOEXTEND_SIZE,''),'</td><td>',ifnull(CREATION_TIME,''),'</td><td>',ifnull(LAST_UPDATE_TIME,''),'</td><td>',ifnull(LAST_ACCESS_TIME,''),'</td><td>',ifnull(RECOVER_TIME,''),'</td><td>',ifnull(TRANSACTION_COUNTER,''),'</td><td>',ifnull(VERSION,''),'</td><td>',ifnull(ROW_FORMAT,''),'</td><td>',ifnull(TABLE_ROWS,''),'</td><td>',ifnull(AVG_ROW_LENGTH,''),'</td><td>',ifnull(DATA_LENGTH,''),'</td><td>',ifnull(MAX_DATA_LENGTH,''),'</td><td>',ifnull(INDEX_LENGTH,''),'</td><td>',ifnull(DATA_FREE,''),'</td><td>',ifnull(CREATE_TIME,''),'</td><td>',ifnull(UPDATE_TIME,''),'</td><td>',ifnull(CHECK_TIME,''),'</td><td>',ifnull(CHECKSUM,''),'</td><td>',ifnull(STATUS,''),'</td><td>',ifnull(EXTRA,''),'</td></tr>') 
from (SELECT * FROM INFORMATION_SCHEMA.FILES a WHERE FILE_TYPE <>'TABLESPACE' or a.TABLESPACE_NAME in ('innodb_system','innodb_temporary')) V

UNION ALL 
SELECT '</table>' 
;

select  '<center>[<a class="noLink" href="#directory">回到目录</a>]</center><p></hr>';
select  '<hr><p><p>';


-- +----------------------------------------------------------------------------+
-- +----------------------------------------------------------------------------+
-- |                             - ALL_USES  -                                  |
-- +----------------------------------------------------------------------------+

select  '<a name="ALL_USES"></a>';
select  '<p><font size="+1" face="Consolas" color="#336699"><b>● 查询所有用户</b></font>';

SELECT '<table border=1><tr><th>Host</th><th>User</th><th>Select_priv</th><th>Insert_priv</th><th>Update_priv</th><th>Delete_priv</th><th>Create_priv</th><th>Drop_priv</th><th>Reload_priv</th><th>Shutdown_priv</th><th>Process_priv</th><th>File_priv</th><th>Grant_priv</th><th>References_priv</th><th>Index_priv</th><th>Alter_priv</th><th>Show_db_priv</th><th>Super_priv</th><th>Create_tmp_table_priv</th><th>Lock_tables_priv</th><th>Execute_priv</th><th>Repl_slave_priv</th><th>Repl_client_priv</th><th>Create_view_priv</th><th>Show_view_priv</th><th>Create_routine_priv</th><th>Alter_routine_priv</th><th>Create_user_priv</th><th>Event_priv</th><th>Trigger_priv</th><th>Create_tablespace_priv</th><th>ssl_type</th><th>ssl_cipher</th><th>x509_issuer</th><th>x509_subject</th><th>max_questions</th><th>max_updates</th><th>max_connections</th><th>max_user_connections</th><th>plugin</th></tr>'

UNION ALL 
SELECT concat('<tr><td>',Host,'</td><td>',User,'</td><td>',Select_priv,'</td><td>',Insert_priv,'</td><td>',Update_priv,'</td><td>',Delete_priv,'</td><td>',Create_priv,'</td><td>',Drop_priv,'</td><td>',Reload_priv,'</td><td>',Shutdown_priv,'</td><td>',Process_priv,'</td><td>',File_priv,'</td><td>',Grant_priv,'</td><td>',References_priv,'</td><td>',Index_priv,'</td><td>',Alter_priv,'</td><td>',Show_db_priv,'</td><td>',Super_priv,'</td><td>',Create_tmp_table_priv,'</td><td>',Lock_tables_priv,'</td><td>',Execute_priv,'</td><td>',Repl_slave_priv,'</td><td>',Repl_client_priv,'</td><td>',Create_view_priv,'</td><td>',Show_view_priv,'</td><td>',Create_routine_priv,'</td><td>',Alter_routine_priv,'</td><td>',Create_user_priv,'</td><td>',Event_priv,'</td><td>',Trigger_priv,'</td><td>',Create_tablespace_priv,'</td><td>',ssl_type,'</td><td>',ssl_cipher,'</td><td>',x509_issuer,'</td><td>',x509_subject,'</td><td>',max_questions,'</td><td>',max_updates,'</td><td>',max_connections,'</td><td>',max_user_connections,'</td><td>',plugin,'</td><tr>') 
from (select * from mysql.user) V

UNION ALL 
SELECT '</table>' 
;


select  '<center>[<a class="noLink" href="#directory">回到目录</a>]</center><p></hr>';
select  '<hr><p><p>';


-- +----------------------------------------------------------------------------+
-- +----------------------------------------------------------------------------+
-- |                             - IMPORTANT_INIT  -                            |
-- +----------------------------------------------------------------------------+

select  '<a name="IMPORTANT_INIT"></a>';
select  '<p><font size="+1" face="Consolas" color="#336699"><b>● 重要的参数 </b></font>';


-- select  '</br><textarea style="width:1100px;font-family:Consolas;font-size:11px;overflow:auto;background-color:#FFFFCC" rows="40">';
-- 
-- show global VARIABLES where  VARIABLE_NAME in ('datadir','SQL_MODE','socket','TIME_ZONE','tx_isolation','transaction_isolation','autocommit','innodb_lock_wait_timeout','max_connections','max_user_connections','slow_query_log','log_output','slow_query_log_file','long_query_time','log_queries_not_using_indexes','log_throttle_queries_not_using_indexes','log_throttle_queries_not_using_indexes','pid_file','log_error','lower_case_table_names','innodb_buffer_pool_size','innodb_flush_log_at_trx_commit','read_only', 'log_slave_updates','innodb_io_capacity','query_cache_type','query_cache_size','max_connect_errors','server_id','innodb_file_per_table') ;
-- 
-- select  '</textarea>';


SELECT '<table border=1><tr><th>VARIABLE_NAME</th><th>VARIABLE_VALUE</th></tr>'
UNION ALL
SELECT concat('<tr><td>',VARIABLE_NAME,'</td><td>',VARIABLE_VALUE,'</td></tr>') 
from (select * from performance_schema.global_variables where  VARIABLE_NAME  
in ( 'datadir','SQL_MODE','socket','TIME_ZONE','tx_isolation','transaction_isolation',
'autocommit','innodb_lock_wait_timeout','max_connections','max_user_connections',
'slow_query_log','log_output','slow_query_log_file','long_query_time','log_queries_not_using_indexes',
'log_throttle_queries_not_using_indexes','log_throttle_queries_not_using_indexes','pid_file','log_error',
'lower_case_table_names','innodb_buffer_pool_size','innodb_flush_log_at_trx_commit','read_only', 'log_slave_updates','innodb_io_capacity',
'query_cache_type','query_cache_size','max_connect_errors','server_id','innodb_file_per_table',
'wait_timeout','sync_binlog','innodb_log_file_size','log_bin')) V
UNION ALL 
SELECT '</table>'
;


select  '<center>[<a class="noLink" href="#directory">回到目录</a>]</center><p></hr>';
select  '<hr><p><p>';


-- +----------------------------------------------------------------------------+
-- +----------------------------------------------------------------------------+
-- |                             - PARTITIONS_INFO  -                           |
-- +----------------------------------------------------------------------------+

select  '<a name="PARTITIONS_INFO"></a>';
select  '<p><font size="+1" face="Consolas" color="#336699"><b>● 分区表信息</b></font>';

SELECT '<table border=1><tr><th>TABLE_SCHEMA</th><th>TABLE_NAME</th><th>PARTITION_TOTAL</th><th>TABLE_ROWS</th><th>DATA_MB</th><th>INDEX_MB</th><th>TOTAL_MB</th></tr>'
UNION ALL
SELECT concat('<tr><td>',TABLE_SCHEMA,'</td><td>',TABLE_NAME,'</td><td>',PARTITION_TOTAL,'</td><td>',TABLE_ROWS,'</td><td>',DATA_MB,'</td><td>',INDEX_MB,'</td><td>',TOTAL_MB,'</td></tr>') 
from (SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    count(distinct PARTITION_NAME) PARTITION_TOTAL,
    sum(TABLE_ROWS) TABLE_ROWS,
    sum(ROUND(DATA_LENGTH / 1024 / 1024, 2)) AS `DATA_MB`,
    sum(ROUND(INDEX_LENGTH / 1024 / 1024, 2)) AS `INDEX_MB`,
    sum(ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024, 2)) AS `TOTAL_MB`
FROM INFORMATION_SCHEMA.PARTITIONS
WHERE TABLE_SCHEMA not in ('information_schema','sys','mysql','performance_schema')
AND PARTITION_NAME IS NOT NULL
group by TABLE_SCHEMA,TABLE_NAME
ORDER BY 1,2,7 desc) V
UNION ALL 
SELECT '</table>'
;


select  '<center>[<a class="noLink" href="#directory">回到目录</a>]</center><p></hr>';
select  '<hr><p><p>';

-- +----------------------------------------------------------------------------+
-- +----------------------------------------------------------------------------+
-- |                             - BIGDQL  -                                    |
-- +----------------------------------------------------------------------------+

select  '<a name="BIGDQL"></a>';
select  '<p><font size="+1" face="Consolas" color="#336699"><b>● 大查询监控</b></font>';

SELECT '<table border=1><tr><th>ID</th><th>USER</th><th>HOST</th><th>DB</th><th>TIME</th><th>STATE</th><th>SQL_INFO</th></tr>'
UNION ALL
SELECT concat('<tr><td>',ID,'</td><td>',USER,'</td><td>',HOST,'</td><td>',DB,'</td><td>',TIME,'</td><td>',STATE,'</td><td>',SQL_INFO,'</td></tr>') 
from (
SELECT 
    p.ID,
    p.USER,
    p.HOST,
    p.DB,
    p.TIME,
    p.STATE,
    LEFT(p.INFO, 200) AS `SQL_INFO`
FROM information_schema.PROCESSLIST p
WHERE p.TIME > 60
AND p.COMMAND = 'Query'
AND p.INFO NOT LIKE '%PROCESSLIST%'
ORDER BY p.TIME DESC
) V
UNION ALL 
SELECT '</table>'
;

select  '<a name="html_bottom_link"></a>';
select  '<center>[<a class="noLink" href="#directory">回到目录</a>]</center><p></hr>';
select  '<hr><p><p>';
quit
