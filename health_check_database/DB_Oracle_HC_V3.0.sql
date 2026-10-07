
-- |------------------------------------------------------------------------------------|
-- |                          DB_Oracle_HC By Jeames                                       |
-- |------------------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                                  |
-- | FILE     : DB_Oracle_HC.sql                                                        |
-- | CLASS    : Database Administration                                                 |
-- | PURPOSE  : This SQL script provides a detailed report (in HTML format)             |
-- | VERSION  : This script was designed for Oracle Database 10g 11g 12c、18c、19c       |
-- | NOTE     : AS with any code, ensure to test this script in a development           |
-- |            environment before attempting to run it in production.                  |
-- +------------------------------------------------------------------------------------+


prompt Note1: 本次巡检会话信息


set line 9999 
col CREATED format a20
col DATABASE_ROLE format a20
col LOG_MODE format a13
col OPEN_MODE format a20
col VERSION format a10
col sessionid format a20

BREAK ON  REPORT ON CON_ID ON INST_ID ON OWNER ON INSTANCE_NUMBER ON INSTANCE_NAME	 ON PNAME ON  ts_name ON  pdbname ON bs_key ON ROLE ON SNAP_ID ON snap_date


SELECT d.DBID,
       d.NAME,
       d.DATABASE_ROLE,
       TO_CHAR(d.CREATED, 'yyyy-mm-dd HH24:mi:ss') CREATED,
       d.LOG_MODE,
       d.OPEN_MODE,
       (SELECT b.VERSION FROM v$instance b WHERE ROWNUM = 1) VERSION,
       (SELECT a.SID || ',' || b.SERIAL# || ',' || c.SPID
          FROM v$mystat a, v$session b, v$process c
         WHERE a.SID = b.SID
           AND  b.PADDR = c.ADDR
           AND  ROWNUM = 1) sessionid
  FROM v$database d;


prompt Note2: Do not modify any inspection results 
prompt


prompt 
prompt +----------------------------------------------------------------------------+
prompt 巡检脚本执行过程将持续数分钟,随库的大小不同而变化。
prompt 开始执行......
prompt +----------------------------------------------------------------------------+
prompt


-- +----------------------------------------------------------------------------+
-- |                           SCRIPT SETTINGS                                  |
-- +----------------------------------------------------------------------------+



set termout       off
set echo          off
set feedback      off
set heading       off
set verify        off
set wrap          on
set trimspool     on
set serveroutput  on
set escape        on
set sqlblanklines on
set ARRAYSIZE  500

set pagesize 50000
set linesize 32767
set numwidth 50
set long     2000000000 LONGCHUNKSIZE 100000

clear buffer computes columns
alter session set NLS_DATE_FORMAT='YYYY-MM-DD HH24:mi:ss';

prompt

host echo '-----Oracle Database  Check STRAT，Starting Collect Data Dictionary Information----'	

prompt 请等待......
host echo start.....设置环境变量、配置html表头....


--------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------


-- +----------------------------------------------------------------------------+
-- |                   GATHER DATABASE REPORT INFORMATION                       |
-- +----------------------------------------------------------------------------+

COLUMN tdate NEW_VALUE _date NOPRINT
COLUMN time NEW_VALUE _time NOPRINT
COLUMN date_time NEW_VALUE _date_time NOPRINT
COLUMN spool_time NEW_VALUE _spool_time NOPRINT
COLUMN date_time_timezone NEW_VALUE _date_time_timezone NOPRINT
COLUMN v_current_user NEW_VALUE _v_current_user NOPRINT
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD') tdate,
       TO_CHAR(SYSDATE, 'HH24:MI:SS') time,
       TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') date_time,
       TO_CHAR(systimestamp, 'YYYY-MM-DD  (') ||
       TRIM(TO_CHAR(systimestamp, 'Day')) ||
       TO_CHAR(systimestamp, ') HH24:MI:SS AM') ||
       TO_CHAR(systimestamp, ' "timezone" TZR') date_time_timezone,
       TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS') spool_time,
       user v_current_user
  FROM dual;

COLUMN dbVERSION NEW_VALUE _dbVERSION NOPRINT
COLUMN dbVERSION1 NEW_VALUE _dbVERSION1 NOPRINT
COLUMN host_name NEW_VALUE _host_name NOPRINT
COLUMN instance_name1 NEW_VALUE _instance_name NOPRINT
COLUMN instance_number NEW_VALUE _instance_number NOPRINT
COLUMN thread_number NEW_VALUE _thread_number NOPRINT
SELECT b.VERSION       dbVERSION,
       host_name       host_name,
       instance_name   instance_name1,
       instance_number instance_number,
       thread#         thread_number,
       substr(b.VERSION,1,instr(b.VERSION,'.')-1) dbVERSION1 
  FROM v$instance b;


COLUMN startup_time NEW_VALUE _startup_time NOPRINT
SELECT TO_CHAR(startup_time, 'YYYY-MM-DD HH24:MI:SS') AS startup_time FROM v$instance;

COLUMN dbname1 NEW_VALUE _dbname1 NOPRINT
COLUMN dbid NEW_VALUE _dbid NOPRINT
COLUMN dbname NEW_VALUE _dbname NOPRINT
COLUMN reporttitle NEW_VALUE _reporttitle NOPRINT
COLUMN platform_name NEW_VALUE _platform_name NOPRINT
COLUMN FORCE_LOGGING NEW_VALUE _FORCE_LOGGING NOPRINT
COLUMN FLASHBACK_ON NEW_VALUE _FLASHBACK_ON NOPRINT
COLUMN platform_id NEW_VALUE _platform_id NOPRINT
COLUMN creation_date NEW_VALUE _creation_date NOPRINT
COLUMN log_mode NEW_VALUE _log_mode NOPRINT
COLUMN DB_ROLE NEW_VALUE _DB_ROLE NOPRINT
SELECT DECODE((SELECT b.parallel FROM v$instance b), 'YES', (d.NAME || '_' ||  (SELECT b.INSTANCE_NUMBER FROM v$instance b)), 'NO', d.NAME)   dbname1,  
       name dbname,
       dbid dbid,
       'DB_healthcheck_by_' || name || '_' ||DECODE((SELECT b.parallel FROM v$instance b), 'YES', (SELECT b.INSTANCE_NUMBER FROM v$instance b)|| '_', 'NO', '')  || (SELECT b.VERSION FROM v$instance b) || '_' ||TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS') reporttitle,
       platform_name platform_name,
       d.FORCE_LOGGING,
       d.FLASHBACK_ON,
       platform_id platform_id ,
       TO_CHAR(CREATED, 'YYYY-MM-DD HH24:MI:SS') creation_date ,
       (case when log_mode ='NOARCHIVELOG' then log_mode else log_mode||','||(SELECT a.DESTINATION FROM v$archive_dest a where a.DESTINATION IS NOT NULL  and rownum<=1) end) log_mode,
       D.DATABASE_ROLE   DB_ROLE 
  FROM  v$database d;


COLUMN global_name NEW_VALUE _global_name NOPRINT
SELECT global_name global_name FROM global_name;

COLUMN blocksize NEW_VALUE _blocksize NOPRINT
SELECT value blocksize FROM v$parameter WHERE name='db_block_size';

COLUMN characterset NEW_VALUE _characterset NOPRINT
SELECT a.VALUE characterset FROM V$NLS_PARAMETERS a WHERE PARAMETER = 'NLS_CHARACTERSET';

COLUMN timezone NEW_VALUE _timezone NOPRINT
SELECT d.version timezone FROM v$timezone_file d ;

COLUMN DGINFO NEW_VALUE _DGINFO NOPRINT
COLUMN DGINFO2 NEW_VALUE _DGINFO2 NOPRINT
SELECT case
         WHEN d.VALUE is null then
          'NO'
         else
          d.VALUE
       end DGINFO,
       case
         WHEN d.VALUE is null then
          '本库未配置DG环境'
         else
          d.VALUE
       end DGINFO2
  FROM v$parameter d
 WHERE d.NAME = 'log_archive_config';

COLUMN cluster_database NEW_VALUE _cluster_database NOPRINT
SELECT value cluster_database FROM v$parameter WHERE name='cluster_database';

COLUMN cluster_database_instances NEW_VALUE _cluster_database_instances NOPRINT
SELECT value cluster_database_instances FROM v$parameter WHERE name='cluster_database_instances';


COLUMN rac_database NEW_VALUE _rac_database NOPRINT 
SELECT (SELECT value cluster_database
          FROM v$parameter
         WHERE name = 'cluster_database') || ' : ' ||
       (SELECT value cluster_database_instances
          FROM v$parameter
         WHERE name = 'cluster_database_instances') rac_database
  FROM DUAL;


---pdbs
COLUMN snap_id NEW_VALUE _snap_id NOPRINT 
COLUMN snap_id1 NEW_VALUE _snap_id1 NOPRINT
SELECT 1 snap_id, 2 snap_id1 FROM dual;
SELECT snap_id   ,snap_id1
  FROM (SELECT d.snap_id, lead(d.snap_id) over(partition by d.startup_time ORDER BY snap_id) snap_id1
          FROM dba_hist_snapshot d,v$instance nd
         WHERE d.instance_number = nd.INSTANCE_NUMBER  
         ORDER BY d.snap_id desc) t 
 WHERE snap_id1 IS NOT NULL
   AND  ROWNUM = 1;


COLUMN v_SID NEW_VALUE _v_SID NOPRINT
COLUMN v_SERIAL# NEW_VALUE _v_SERIAL NOPRINT
COLUMN v_SPID NEW_VALUE _v_SPID NOPRINT
COLUMN v_sessionid NEW_VALUE _v_sessionid NOPRINT
SELECT a.SID v_SID,
       b.SERIAL# v_SERIAL#,
       c.SPID v_SPID,
       'INST_ID：'||b.INST_ID||',【'||a.SID||','||b.SERIAL# ||','||c.SPID||'】' v_sessionid  
FROM   v$mystat  a,
       gv$session b ,
       v$process c
WHERE  a.SID = b.SID
and b.PADDR=c.ADDR
AND    ROWNUM = 1;

COLUMN  nls_language NEW_VALUE _nls_language NOPRINT 
SELECT d.VALUE nls_language FROM v$parameter d WHERE d.NAME='nls_language';

--------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------

-- +----------------------------------------------------------------------------+
-- |                   GATHER DATABASE REPORT INFORMATION                       |
-- +----------------------------------------------------------------------------+

set heading on

set markup html on spool on preformat off entmap on -
head ' -
  <title>&_dbname1 巡检报告</title> -
  <style type="text/css"> -
    body p            {font:11px Consolas; color:black; background:White;} -
    table             {font:11px Consolas; color:Black; background:#FFFFCC; padding:1px; margin:0px 0px 0px 0px;} -
	tr:nth-child(odd) {background:White;} -
	tr:hover          {background-color: yellow;} -
    th                {font:bold 11px Consolas; color:White; background:#0066cc; padding:5px;white-space: nowrap;} -
    a a.link          {font:11px Consolas; color:#663300; margin-top:0pt; margin-bottom:0pt; vertical-align:middle;padding:4;} -
    a.noLink          {font:11px Consolas; color:#663300; text-decoration: underline; margin-top:0pt; margin-bottom:0pt; vertical-align:middle;padding:4;} -
    a.info:hover {background:#eee;color:#000000; position:relative;} -
    a.info span {display: none; } -
    a.info:hover span {font-size:11px!important; color:#000000; display:block;position:absolute;top:30px;left:40px;width:150px;border:1px solid #ff0000; background:#FFFF00; padding:1px 1px;text-align:left;word-wrap: break-word; white-space: pre-wrap} -
  </style>' -
body   'BGCOLOR="#C0C0C0"'


SET MARKUP html TABLE  'border="1" summary="Script output" cellspacing="0px" style="border-collapse:collapse;" ' 

spool &_reporttitle..html

set markup html on ENTMAP OFF


 
-- +----------------------------------------------------------------------------+
-- +----------------------------------------------------------------------------+
-- |                             - REPORT HEADER -                              |
-- +----------------------------------------------------------------------------+

define reportHeader="<center><font size=+3 color=darkgreen><b>&_dbname 数据库巡检报告</b></font></center>"


prompt <a name=top></a>
prompt &reportHeader
prompt <hr>
prompt <a style="font-weight:lighter">巡 检：公众号（IT邦德）</a>
prompt <a style="font-weight:lighter">巡检时间：&_date_time</a>
prompt <a style="font-weight:lighter">版 本 号：v3.0.0</a>
prompt 
prompt [<a class="noLink" href="#html_bottom_link">转到页底</a>]
prompt <hr>

prompt <a name="directory"><font size=+2 face="Consolas" color="#336699"><b>目录</b></font></a>
prompt <hr>
prompt <table width="100%" border="1" bordercolor="#000000" cellspacing="0px" style="border-collapse:collapse; margin-top:-2cm;" align="center"> -
<tr><th colspan="6"><a class="info" href="#database_check_overview"><font size=+0.5 face="Consolas" color="#ffffff"><b>巡检明细</b></font></a></th></tr> -
<tr style="background:#FFFFCC;"> -
<td style="background-color:#FFCC00" rowspan="1"  nowrap align="center" width="10%"><a class="info" href="#database_ztgk"><font size=+0.5 face="Consolas" color="#000000"><b>数据库总体概况</b><span> </span></font></a></td> -
<td nowrap align="center" width="18%"><a class="info" href="#basic_info"><font size=+0.5 face="Consolas" color="#336699">数据库基本信息<span>数据库的总体概况、DG、OGG、版本、PSU、主机情况、数据库属性等</span></font></a></td> -
<td nowrap align="center" width="18%"><a class="info" href="#rman_backup_info"><font size=+0.5 face="Consolas" color="#336699">RMAN备份<span> 备份及配置信息</span></font></a></td> -
<td nowrap align="center" width="18%"><a class="info" href="#logsize"><font size=+0.5 face="Consolas" color="#336699">REDO日志组</font></a></td> -
<td nowrap align="center" width="18%"><a class="info" href="#invalid_objects"><font size=+0.5 face="Consolas" color="#336699">无效的对象</font></a></td> -
<td nowrap align="center" width="18%"><a class="info" href="#UNUSABLE_index"><font size=+0.5 face="Consolas" color="#336699">无效索引<span>无效的普通及分区索引</span></font></a></td> -
</tr>
prompt <tr style="background:#FFFFCC;"> -
<td style="background-color:#FFCC00" rowspan="1"  nowrap align="center" width="10%"><a class="info" href="#spfile_info"><font size=+0.5 face="Consolas" color="#000000"><b>参数文件</b><span> </span></font></a></td> -
<td nowrap align="center" width="18%"><a class="info" href="#initial_parameter_info"><font size=+0.5 face="Consolas" color="#336699">关键的初始化参数</font></a></td> -
<td nowrap align="center" width="18%"><a class="info" href="#Implicit_parameters"><font size=+0.5 face="Consolas" color="#336699">隐含参数<span>系统隐含参数修改需慎重</span></font></a></td> -
<td nowrap align="center" width="18%"><a class="info" href="#flashback_database_info"><font size=+0.5 face="Consolas" color="#336699">数据库闪回<span>Flashback</span></font></a></td> -
<td nowrap align="center" width="18%"><a class="info" href="#link_dg_config"><font size=+0.5 face="Consolas" color="#336699">DG相关的参数</font></a></td> -
<td nowrap align="center" width="18%"><a class="info" href="#control_files_all"><font size=+0.5 face="Consolas" color="#336699">控制文件</font></a></td> -
</tr>
prompt <tr style="background:#FFFFCC;"> -
<td style="background-color:#FFCC00" rowspan="1"  nowrap align="center" width="10%"><a class="info" href="#database_tablespace_qk"><font size=+0.5 face="Consolas" color="#000000"><b>空间使用情况</b><span> </span></font></a></td> -
<td nowrap align="center" width="18%"><a class="info" href="#tablespaces_info"><font size=+0.5 face="Consolas" color="#336699">表空间状况信息</font></a></td> -
<td nowrap align="center" width="18%"><a class="info" href="#flash_usage"><font size=+0.5 face="Consolas" color="#336699">闪回空间使用情况</font></a></td> -
<td nowrap align="center" width="18%"><a class="info" href="#ts_temp_usage"><font size=+0.5 face="Consolas" color="#336699">临时表空间使用情况</font></a></td> -
<td nowrap align="center" width="18%"><a class="info" href="#ts_partition_usage"><font size=+0.5 face="Consolas" color="#336699">分区使用情况</font></a></td> -
<td nowrap align="center" width="18%"><a class="info" href="#"><font size=+0.5 face="Consolas" color="#336699"></font></a></td> -
</tr>
prompt <tr style="background:#FFFFCC;"> -
<td style="background-color:#FFCC00" rowspan="1"  nowrap align="center" width="10%"><a class="info" href="#database_asmdiskcheck"><font size=+0.5 face="Consolas" color="#000000"><b>ASM磁盘</b><span> </span></font></a></td> -
<td nowrap align="center" width="18%"><a class="info" href="#asm_disk"><font size=+0.5 face="Consolas" color="#336699">ASM磁盘</font></a></td> -
<td nowrap align="center" width="18%"><a class="info" href="#asm_diskgroup"><font size=+0.5 face="Consolas" color="#336699">ASM磁盘组使用情况</font></a></td> -
<td nowrap align="center" width="18%"><a class="info" href="#asm_diskgroupinstance"><font size=+0.5 face="Consolas" color="#336699">ASM实例</font></a></td> -
<td nowrap align="center" width="18%"><a class="info" href="#"><font size=+0.5 face="Consolas" color="#336699"></font></a></td> -
<td nowrap align="center" width="18%"><a class="info" href="#"><font size=+0.5 face="Consolas" color="#336699"></font></a></td> -
</tr>
prompt <tr style="background:#FFFFCC;"> -
<td style="background-color:#FFCC00" rowspan="1"  nowrap align="center" width="10%"><a class="info" href="#other_situations"><font size=+0.5 face="Consolas" color="#000000"><b>其他</b><span> </span></font></a></td> -
<td nowrap align="center" width="18%"><a class="info" href="#parallel_check"><font size=+0.5 face="Consolas" color="#336699">并行度检查</font></a></td> -
<td nowrap align="center" width="18%"><a class="info" href="#user_secure"><font size=+0.5 face="Consolas" color="#336699">用户安全</font></a></td> -
<td nowrap align="center" width="18%"><a class="info" href="#performance_info"><font size=+0.5 face="Consolas" color="#336699">性能分析</font></a></td> -
<td nowrap align="center" width="18%"><a class="info" href="#jobs_info"><font size=+0.5 face="Consolas" color="#336699">jobs运行状况</font></a></td> -
<td nowrap align="center" width="18%"><a class="info" href="#awr_new_lastone_link"><font size=+0.5 face="Consolas" color="#336699">AWR报告</font></a></td> -
</tr>
prompt </table>


prompt <br />
prompt <hr>
prompt <br />
 

-- +====================================================================================================================+
-- |
-- |                                     <<<<<     数据库巡检服务概要     >>>>>                                         |
-- |                                                                                                                    |
-- +====================================================================================================================+

host echo  start...数据库巡检服务概要. . 


prompt <a name="database_check_overview"></a>
prompt <center><font size="+2" face="Consolas" color="#663300"><b><u>数据库巡检服务概要</u></b></font></center>
prompt <p>


host echo "            数据库总体概况. . ." 
prompt <a name="database_ztgk"></a>
prompt <font size="+2" color="00CCFF"><b>数据库总体概况</b></font><hr align="left" width="800">
prompt <p>

-- +----------------------------------------------------------------------------+
-- |                           - DATABASE OVERVIEW -                            |
-- +----------------------------------------------------------------------------+
prompt <a name="basic_info"></a>
prompt <font size="+2" face="Consolas" color="#336699"><b>数据库基本信息</b></font><hr align="left" width="600">
prompt <table width="1100" border="1" bordercolor="#000000" cellspacing="0px" style="font-family:Consolas;border-collapse:collapse"> -
<tr><th align="left" width="150">巡检报告文件名称</th><td width="950"><font face="Consolas">&_reporttitle..html</font></td></tr> -
<tr><th align="left" width="150">巡检时间</th><td width="950"><font face="Consolas">&_date_time_timezone</font></td></tr> -
<tr><th align="left" width="150">当前巡检用户</th><td width="950"><font face="Consolas">&_v_current_user</font></td></tr> -
<tr><th align="left" width="150">当前巡检会话</th><td width="950"><font face="Consolas">&_v_sessionid</font></td></tr> -
<tr><th align="left" width="150">操作系统信息</th><td width="950"><font face="Consolas">&_platform_name / &_platform_id</font></td></tr> -
<tr><th align="left" width="150">数据库名称</th><td width="950"><font face="Consolas">&_dbname</font></td></tr> -
<tr><th align="left" width="150">数据库全局名</th><td width="950"><font face="Consolas">&_global_name</font></td></tr> -
<tr><th align="left" width="150">当前实例名</th><td width="950"><font face="Consolas">&_instance_name</font></td></tr> -
<tr><th align="left" width="150">数据库版本</th><td width="950"><font face="Consolas">&_dbversion</font></td></tr> -
<tr><th align="left" width="150">数据库ID(DBID)</th><td width="950"><font face="Consolas">&_dbid</font></td></tr> -
<tr><th align="left" width="150">是否RAC集群及其节点数</th><td width="950"><font face="Consolas">&_rac_database</font></td></tr> -
<tr><th align="left" width="150">数据库创建时间</th><td width="950"><font face="Consolas">&_creation_date</font></td></tr> -
<tr><th align="left" width="150">实例启动时间</th><td width="950"><font face="Consolas">&_startup_time</font></td></tr> -
</table>
prompt <table width="1100" border="1" bordercolor="#000000" cellspacing="0px" style="font-family:Consolas;border-collapse:collapse; margin-top:-17px;"> -
<tr><th align="left" width="150">数据库归档模式</th><td width="950"><font face="Consolas">&_log_mode</font></td></tr> -
<tr><th align="left" width="150">数据库闪回状态</th><td width="950"><font face="Consolas">&_FLASHBACK_ON</font></td></tr> -
<tr><th align="left" width="150">数据库字符集</th><td width="950"><font face="Consolas">&_characterset</font></td></tr> -
<tr><th align="left" width="150">数据库块大小</th><td width="950"><font face="Consolas">&_blocksize</font></td></tr> -
<tr><th align="left" width="150">强制日志</th><td width="950"><font face="Consolas">&_FORCE_LOGGING</font></td></tr> -
<tr><th align="left" width="150">数据库角色</th><td width="950"><font face="Consolas">&_DB_ROLE</font></td></tr> -
<tr><th align="left" width="150">是否有DG</th><td width="950"><font face="Consolas">&_DGINFO</font></td></tr> -
<tr><th align="left" width="150">db time zone</th><td width="950"><font face="Consolas">&_timezone</font></td></tr> -
</table>

 
prompt <a name="database_version"></a>
prompt <font size="+1" face="Consolas" color="#336699"><b>● 数据库系统版本信息</b></font>

CLEAR COLUMNS COMPUTES
SET DEFINE OFF

COLUMN banner   FORMAT a300   HEADING '数据库系统版本信息'


SELECT banner FROM v$version;

prompt <a name="database_version"></a>
prompt <font size="+1" face="Consolas" color="#336699"><b>● 数据库系统PSU信息</b></font>

CLEAR COLUMNS COMPUTES
SET DEFINE OFF

col action_time   for a30
col action       for a10
col namespace     for a10
col version       for a10
col bundle_series for a10
col comments    for a30

SELECT to_char(d.action_time, 'YYYY-MM-DD HH24:MI:SS') action_time,
       d.action,
       d.namespace,
       d.id,
       --d.bundle_series,
       d.comments
  FROM dba_REGISTRY_HISTORY d
 order by d.action_time;

prompt <a name="database_version"></a>
prompt <font size="+1" face="Consolas" color="#336699"><b>● 私网网卡信息</b></font>

CLEAR COLUMNS COMPUTES
SET DEFINE OFF

col IS_PUBLIC   for a10
SELECT * FROM gv$cluster_interconnects D;

prompt <a name="instance_info"></a>
prompt <font size="+1" face="Consolas" color="#336699"><b>● 数据库实例状况</b></font>

CLEAR COLUMNS COMPUTES
SET DEFINE OFF


COLUMN instance_name_print       FORMAT a75    HEADING '数据库实例名称'       ENTMAP OFF
COLUMN instance_number_print     FORMAT a75    HEADING '数据库实例号'        ENTMAP OFF
COLUMN thread_number_print                     HEADING '线程号'          ENTMAP OFF
COLUMN host_name_print           FORMAT a75    HEADING '主机名'           ENTMAP OFF
COLUMN version                                 HEADING '数据库版本'      ENTMAP OFF
COLUMN START_TIME                FORMAT a75    HEADING '实例启动时间'          ENTMAP OFF
COLUMN uptime                                  HEADING '运行时间(天)'    ENTMAP OFF
COLUMN parallel                  FORMAT a75    HEADING 'RAC模式'    ENTMAP OFF
COLUMN instance_status           FORMAT a75    HEADING '实例状态'     ENTMAP OFF
COLUMN database_status           FORMAT a75    HEADING '数据库状态'     ENTMAP OFF
COLUMN logins                    FORMAT a75    HEADING '是否可登录'              ENTMAP OFF
COLUMN archiver                  FORMAT a75    HEADING '是否可归档'            ENTMAP OFF

SELECT '<div align="center"><font color="#336699"><b>' || INSTANCE_NAME ||
       '</b></font></div>' INSTANCE_NAME_PRINT,
       '<div align="center">' || INSTANCE_NUMBER || '</div>' INSTANCE_NUMBER_PRINT,
       '<div align="center">' || THREAD# || '</div>' THREAD_NUMBER_PRINT,
       '<div align="center">' || HOST_NAME || '</div>' HOST_NAME_PRINT,
       '<div align="center">' || VERSION || '</div>' VERSION,
       '<div align="center">' ||
       TO_CHAR(STARTUP_TIME, 'yyyy-mm-dd HH24:MI:SS') || '</div>' START_TIME,
       ROUND(TO_CHAR(SYSDATE - STARTUP_TIME), 2) UPTIME,
       '<div align="center">' || PARALLEL || '</div>' PARALLEL,
       '<div align="center">' || STATUS || '</div>' INSTANCE_STATUS,
       '<div align="center">' || LOGINS || '</div>' LOGINS,
       DECODE(ARCHIVER,
              'FAILED',
              '<div align="center"><b><font color="#990000">' || ARCHIVER ||
              '</font></b></div>',
              '<div align="center"><b><font color="darkgreen">' || ARCHIVER ||
              '</font></b></div>') ARCHIVER
  FROM GV$INSTANCE
 ORDER BY INSTANCE_NUMBER;



prompt <a name="database_overview"></a>
prompt <font size="+1" face="Consolas" color="#336699"><b>● 数据库概要</b></font>

CLEAR COLUMNS COMPUTES
SET DEFINE OFF
	

COLUMN name                            FORMAT a125    HEADING '&nbsp;&nbsp;&nbsp;&nbsp;DB_NAME&nbsp;&nbsp;&nbsp;&nbsp;'              ENTMAP OFF
COLUMN dbid                                           HEADING 'DB_ID'                ENTMAP OFF
COLUMN db_unique_name                                 HEADING 'DB_Unique_Name'       ENTMAP OFF
COLUMN creation_date                   FORMAT a140    HEADING '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;CREATION_DATE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'              ENTMAP OFF
COLUMN platform_name_print             FORMAT a140    HEADING '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;PLATFORM_NAME&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'              ENTMAP OFF
COLUMN current_scn                                    HEADING '当前SCN'                ENTMAP OFF
COLUMN log_mode                                       HEADING '日志模式'                   ENTMAP OFF
COLUMN open_mode                       FORMAT a180    HEADING '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;OPEN_MODE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'                  ENTMAP OFF
COLUMN force_logging                   FORMAT a140    HEADING '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;FORCE_LOGGING&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'              ENTMAP OFF
COLUMN flashback_on                                   HEADING 'Flashback'              ENTMAP OFF
COLUMN controlfile_type                               HEADING '控制文件类型'           ENTMAP OFF
COLUMN SUPPLEMENTAL_LOG_DATA_MIN       FORMAT a25     HEADING 'SUPPLEMENTAL|LOG_DATA_MIN'  ENTMAP OFF
COLUMN SUPPLEMENTAL_LOG_DATA_PK        FORMAT a25     HEADING 'SUPPLEMENTAL|LOG_DATA_PK'  ENTMAP OFF
COLUMN SUPPLEMENTAL_LOG_DATA_MIN       FORMAT a25     HEADING 'SUPPLEMENTAL|LOG_DATA_MIN'  ENTMAP OFF
COLUMN last_open_incarnation#          FORMAT a50     HEADING 'LAST_OPEN|INCARNATION#'  ENTMAP OFF
COLUMN DATABASE_ROLE                   FORMAT a140    HEADING '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;DATABASE_ROLE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'                  ENTMAP OFF



SELECT d.INST_ID,
       '<div align="center"><font color="#336699"><b>' || NAME ||
       '</b></font></div>' NAME,
       '<div align="center">' || dbid || '</div>' dbid,
       '<div align="center">' || db_unique_name || '</div>' db_unique_name,
       '<div align="center">' || TO_CHAR(CREATED, 'yyyy-mm-dd HH24:MI:SS') ||
       '</div>' creation_date,
       '<div align="center">' || platform_name || '</div>' platform_name_print,
       '<div align="center">' || current_scn || '</div>' current_scn,
       '<div align="center">' || log_mode || '</div>' log_mode,
       '<div align="center">' || open_mode || '</div>' open_mode,
       '<div align="center">' || force_logging || '</div>' force_logging,
       '<div align="center">' || flashback_on || '</div>' flashback_on,
       '<div align="center">' || controlfile_type || '</div>' controlfile_type,
       '<div align="center">' || last_open_incarnation# || '</div>' last_open_incarnation#,
       d.DATABASE_ROLE,
       d.SUPPLEMENTAL_LOG_DATA_MIN,
       d.SUPPLEMENTAL_LOG_DATA_PK 
FROM   gv$database d;

prompt <center>[<a class="noLink" href="#directory">回到目录</a>]</center><p>

prompt <br/>


-- +============================================================================+
-- |                                                                            |
-- |                      <<<<<     BACKUPS     >>>>>                           |
-- |                                                                            |
-- +============================================================================+

host echo "     RMAN信息. . ." 
prompt <a name="rman_backup_info"></a>
prompt <font size="+2" face="Consolas" color="#336699"><b>RMAN备份</b></font><hr align="left" width="600">

prompt <b><font face="Consolas" >● Last 14 Day RMAN backup </font></b>

CLEAR COLUMNS COMPUTES
SET DEFINE OFF



COLUMN backup_name           FORMAT a130   HEADING '备份名称'          ENTMAP OFF
COLUMN START_TIME            FORMAT a75    HEADING '开始时间'           ENTMAP OFF
COLUMN elapsed_time          FORMAT a75    HEADING '花费时间'         ENTMAP OFF
COLUMN status                              HEADING '状态'               ENTMAP OFF
COLUMN input_type                          HEADING '输入类型'           ENTMAP OFF
COLUMN output_device_type                  HEADING '输出设备'       ENTMAP OFF
COLUMN input_size                          HEADING '输入大小'           ENTMAP OFF
COLUMN output_size                         HEADING '输出大小'          ENTMAP OFF
COLUMN INPUT_BYTES_PER_SEC                 HEADING '每秒钟写入IO'          ENTMAP OFF
COLUMN output_rate_per_sec                 HEADING '每秒钟读取IO'  ENTMAP OFF

SELECT '<div nowrap><b><font color="#336699">' || r.command_id ||
       '</font></b></div>' backup_name,
       '<div nowrap align="right">' ||
       TO_CHAR(r.START_TIME, 'yyyy-mm-dd HH24:MI:SS') || '</div>' START_TIME,
       '<div nowrap align="right">' || r.time_taken_display || '</div>' elapsed_time,
       ELAPSED_MINUTE,
       DECODE(r.status,
              'COMPLETED',
              '<div align="center"><b><font color="darkgreen">' || r.status ||
              '</font></b></div>',
              'RUNNING',
              '<div align="center"><b><font color="#000099">' || r.status ||
              '</font></b></div>',
              'FAILED',
              '<div align="center"><b><font color="#990000">' || r.status ||
              '</font></b></div>',
              '<div align="center"><b><font color="#663300">' || r.status ||
              '</font></b></div>') status,
       r.input_type input_type,
       r.output_device_type output_device_type,
       '<div nowrap align="right">' || r.input_bytes_display || '</div>' input_size,
       '<div nowrap align="right">' || r.output_bytes_display || '</div>' output_size,
       '<div nowrap align="right">' || r.INPUT_BYTES_PER_SEC_DISPLAY ||
       '</div>' INPUT_BYTES_PER_SEC,
       '<div nowrap align="right">' || r.output_bytes_per_sec_display ||
       '</div>' output_rate_per_sec
  FROM (SELECT command_id,
               START_TIME,
               time_taken_display,
               round(ELAPSED_SECONDS/60,2) ELAPSED_MINUTE,
               status,
               input_type,
               output_device_type,
               input_bytes_display,
               INPUT_BYTES_PER_SEC_DISPLAY,
               output_bytes_display,
               output_bytes_per_sec_display
          FROM v$rman_backup_job_details a
          where START_TIME > sysdate-14
          ORDER BY START_TIME DESC) r;
		  
		  
prompt <b><font face="Consolas" >● RMAN非默认配置 </font></b>

CLEAR COLUMNS COMPUTES
SET DEFINE OFF


COLUMN name     FORMAT a130   HEADING 'Name'   ENTMAP OFF
COLUMN value                  HEADING 'Value'  ENTMAP OFF

SELECT '<div nowrap><b><font color="#336699">' || name || '</font></b></div>' name,
       value
  FROM v$rman_configuration
 ORDER BY name;


prompt <center>[<a class="noLink" href="#directory">回到目录</a>]</center><p>

prompt <br/>

-- +----------------------------------------------------------------------------+
-- |                          - ONLINE REDO LOGS -                              |
-- +----------------------------------------------------------------------------+
 
prompt <a name="logsize"></a>  
prompt <font size="+2" face="Consolas" color="#336699"><b>REDO日志组</b></font><hr align="left" width="600">


prompt <b><font face="Consolas" > 日志组大小 </font></b>

CLEAR COLUMNS COMPUTES
SET DEFINE OFF

SELECT v$logfile.group#,
       v$log.status,
       v$log.ARCHIVED,
       v$log.bytes / 1024 / 1024 MB,
       v$log.thread#
  FROM v$log, v$logfile
WHERE v$log.group# = v$logfile.group#
group by v$logfile.group#,
          v$log.status,
          v$log.ARCHIVED,
          v$log.bytes / 1024 / 1024,
          v$log.thread#
order by 5,1;


prompt <b><font face="Consolas" > 日志组成员 </font></b>

CLEAR COLUMNS COMPUTES
SET DEFINE OFF

select a.group#,
       a.THREAD#,
       a.SEQUENCE#,
       bytes/1024/1024 size_m,
       a.status,
       a.ARCHIVED,
       a.MEMBERS,
       b.MEMBER,
       b.TYPE
FROM   v$log     a,
       v$logfile b
WHERE  b.GROUP# = a.GROUP#
ORDER  BY a.THREAD#,
          a.GROUP#,
          a.SEQUENCE#;
  
prompt <b><font face="Consolas" > 日志切换频率 </font></b>

CLEAR COLUMNS COMPUTES
SET DEFINE OFF

SELECT 
    TRUNC(first_time) AS "DATE",
    COUNT(*) AS "TOTAL",
    ROUND(24 * 60 / COUNT(*), 2) AS "Avg_Minutes_Between_Switches"
FROM 
    v$log_history
WHERE 
    first_time >= SYSDATE - 15
GROUP BY 
    TRUNC(first_time)
ORDER BY 1 DESC;


prompt <b><font face="Consolas" > 归档日志信息 </font></b>

CLEAR COLUMNS COMPUTES
SET DEFINE OFF

SELECT 
    TRUNC(completion_time) AS archived_date,
    COUNT(*) AS total_log_count,
    COUNT(CASE WHEN deleted = 'NO' THEN 1 END) AS not_deleted_count, 
    COUNT(CASE WHEN deleted = 'YES' THEN 1 END) AS deleted_count,
    ROUND(SUM(blocks * block_size) / 1024 / 1024, 2) AS total_size_mb,
    ROUND(SUM(CASE WHEN deleted = 'NO' THEN blocks * block_size ELSE 0 END) / 1024 / 1024, 2) AS not_deleted_size_mb,
    ROUND(SUM(CASE WHEN deleted = 'YES' THEN blocks * block_size ELSE 0 END) / 1024 / 1024, 2) AS deleted_size_mb
FROM 
    v$archived_log
WHERE 
    completion_time >= TRUNC(SYSDATE) - 15
GROUP BY 
    TRUNC(completion_time)
ORDER BY archived_date DESC;

prompt <center>[<a class="noLink" href="#directory">回到目录</a>]</center><p>

prompt <br/>

-- +----------------------------------------------------------------------------+
-- |                          - 无效的对象 -                                    |
-- +----------------------------------------------------------------------------+

prompt <a name="invalid_objects"></a>
prompt <font size="+2" face="Consolas" color="#336699"><b>无效的对象</b></font> [<a class="noLink" href="#UNUSABLE_index">下一项</a>] <hr align="left" width="600">

CLEAR COLUMNS COMPUTES
SET DEFINE OFF


COLUMN owner           FORMAT a85         HEADING 'Owner'         ENTMAP OFF
COLUMN object_name     FORMAT a30         HEADING 'Object Name'   ENTMAP OFF
COLUMN object_type     FORMAT a20         HEADING 'Object Type'   ENTMAP OFF
COLUMN status          FORMAT a75         HEADING 'Status'        ENTMAP OFF

SELECT '<div nowrap align="left"><font color="#336699"><b>' || owner ||
       '</b></font></div>' owner,
       object_name,
       object_type,
       DECODE(status,
              'VALID',
              '<div align="center"><font color="darkgreen"><b>' || status ||
              '</b></font></div>',
              '<div align="center"><font color="#990000"><b>' || status ||
              '</b></font></div>') status,
       'alter ' || DECODE(object_type,
                          'PACKAGE BODY',
                          'PACKAGE',
                          'TYPE BODY',
                          'TYPE',
                          object_type) || ' ' || owner || '.' ||
       object_name || ' ' ||
       DECODE(object_type, 'PACKAGE BODY', 'compile body', 'compile') || ';' hands_on
  FROM dba_objects d
 WHERE owner not in ('SYS','SYSTEM','PUBLIC','MDSYS','TSMSYS','DMSYS','DBSNMP','SCOTT','DB_MONITOR','OUTLN','MGMT_VIEW','FLOWS_FILES','ORDSYS','EXFSYS','WMSYS','APPQOSSYS','APEX_030200','APEX_050000','OWBSYS_AUDIT','ORDDATA','CTXSYS','ANONYMOUS','SYSMAN','XDB','ORDPLUGINS','OWBSYS','SI_INFORMTN_SCHEMA','OLAPSYS','ORACLE_OCM','XS$NULL','BI','PM','MDDATA','IX','SH','DIP','OE','APEX_PUBLIC_USER','HR','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','APEX_040200','DVSYS','LBACSYS','GSMADMIN_INTERNAL','AUDSYS','OJVMSYS','SYS$UMF','GGSYS','DBSFWUSER','DVF','GSMCATUSER','SYSBACKUP','REMOTE_SCHEDULER_AGENT','GSMUSER','SYSRAC','SYSKM','SYSDG','PDBADMIN','WKSYS','GSMROOTUSER')
   AND status <> 'VALID'
   AND rownum<=100
 ORDER BY owner, object_name;



prompt <center>[<a class="noLink" href="#directory">回到目录</a>]</center><p>

prompt <br/>


-- +----------------------------------------------------------------------------+
-- |                          - 无效的索引 -                                    |
-- +----------------------------------------------------------------------------+

prompt <a name="UNUSABLE_index"></a>
prompt <font size="+2" face="Consolas" color="#336699"><b>无效索引</b></font><hr align="left" width="600">

CLEAR COLUMNS COMPUTES
SET DEFINE OFF

select 'partition_idx' type,index_owner OWNER, INDEX_NAME,status from dba_ind_partitions where status!='USABLE'
union
select 'indexes' type,OWNER, index_name,status from dba_indexes where status not in ('N/A','VALID');

prompt <center>[<a class="noLink" href="#directory">回到目录</a>]</center><p>

prompt <br/>


-- +----------------------------------------------------------------------------+
-- |                           - spfile_info  -                                 |
-- +----------------------------------------------------------------------------+

prompt <a name="spfile_info"></a>
prompt <font size="+2" color="00CCFF"><b>参数文件</b></font><hr align="left" width="800">

prompt <br/>
prompt <a name="initial_parameter_info"></a>
prompt <font size="+2" face="Consolas" color="#336699"><b>关键的初始化参数</b></font><hr align="left" width="600">

CLEAR COLUMNS COMPUTES
SET DEFINE OFF

COLUMN pname                FORMAT a75    HEADING '参数名称'    ENTMAP OFF
COLUMN instance_name_print  FORMAT a45    HEADING '实例名称'     ENTMAP OFF
COLUMN value                FORMAT a75    HEADING '参数值'             ENTMAP OFF


SELECT DECODE(p.isdefault,
              'FALSE',
              '<b><font color="#663300">' || SUBSTR(p.name, 0, 512) ||
              '</font></b>',
              '<b><font color="#336699">' || SUBSTR(p.name, 0, 512) ||
              '</font></b>') pname,
       DECODE(p.isdefault,
              'FALSE',
              '<font color="#663300"><b>' || i.instance_name ||
              '</b></font>',
              i.instance_name) instance_name_print,
       DECODE(p.isdefault,
              'FALSE',
              '<font color="#663300"><b>' || SUBSTR(p.value, 0, 512) ||
              '</b></font>',
              SUBSTR(p.value, 0, 512)) value
  FROM gv$parameter p, gv$instance i
 WHERE p.inst_id = i.inst_id
   AND  p.name in ('shared_pool_size','open_cursors','processes','job_queue_processes','sga_max_size','log_archive_dest_1', 'sessions','spfile','control_file_record_keep_time','sga_target','db_cache_size','shared_pool_size','large_pool_size','java_pool_size','log_buffer','pga_aggregate_target','sort_area_size','db_block_size','optimizer_mode','cursor_sharing','open_cursors','optimizer_index_cost_adj','optimizer_index_caching','db_file_multiblock_read_count','hash_join_enabled','thread','instance_number','instance_name','local_listener','audit_trail','commit_point_strength','global_names','job_queue_interval','job_queue_processes','max_transaction_branches','open_links','open_links_per_instance','parallel_automatic_tuning','parallel_max_servers','parallel_min_servers','parallel_server_idle_time','processes','db_files','replication_dependency_tracking','shared_pool_size','pga_aggregate_target','db_create_file_dest')
 ORDER BY p.name, i.instance_name;


prompt <center>[<a class="noLink" href="#directory">回到目录</a>]</center>
 
prompt <a name="Implicit_parameters"></a>
prompt <font size="+2" face="Consolas" color="#336699"><b>隐含参数</b></font></center><p> <hr align="left" width="600">

CLEAR COLUMNS COMPUTES
SET DEFINE OFF
 

COLUMN pname                FORMAT a75    HEADING 'Parameter Name'    ENTMAP OFF
COLUMN instance_name_print  FORMAT a45    HEADING 'Instance_Name'     ENTMAP OFF
COLUMN value                FORMAT a75    HEADING 'Value'             ENTMAP OFF
COLUMN isdefault            FORMAT a75    HEADING 'Is Default?'       ENTMAP OFF
COLUMN issys_modifiable     FORMAT a75    HEADING 'Is Dynamic?'       ENTMAP OFF
COLUMN ISDEPRECATED     FORMAT a75    HEADING 'ISDEPRECATED'       ENTMAP OFF
COLUMN DESCRIPTION     FORMAT a200    HEADING 'DESCRIPTION'       ENTMAP OFF
SET DEFINE ON


SELECT DECODE(p.isdefault,
              'FALSE',
              '<b><font color="#336699">' || SUBSTR(p.name, 0, 512) ||
              '</font></b>',
              '<b><font color="#336699">' || SUBSTR(p.name, 0, 512) ||
              '</font></b>') pname,
       DECODE(p.isdefault,
              'FALSE',
              '<font color="#663300"><b>' || i.instance_name ||
              '</b></font>',
              i.instance_name) instance_name_print,
       DECODE(p.isdefault,
              'FALSE',
              '<font color="#663300"><b>' || SUBSTR(p.value, 0, 512) ||
              '</b></font>',
              SUBSTR(p.value, 0, 512)) value,
       p.DISPLAY_VALUE,
       DECODE(p.isdefault,
              'FALSE',
              '<div align="center"><font color="#663300"><b>' || p.isdefault ||
              '</b></font></div>',
              '<div align="center">' || p.isdefault || '</div>') isdefault,
       DECODE(p.isdefault,
              'FALSE',
              '<div align="right"><font color="#663300"><b>' ||
              p.issys_modifiable || '</b></font></div>',
              '<div align="right">' || p.issys_modifiable || '</div>') issys_modifiable,
       p.ISDEPRECATED,
       p.DESCRIPTION
  FROM gv$parameter p, gv$instance i
 WHERE p.inst_id = i.inst_id
   AND p.NAME like '=_%' escape '='
 ORDER BY p.name, i.instance_name;

  
prompt <center>[<a class="noLink" href="#directory">回到目录</a>] </center><p>


-- +============================================================================+
-- |                                                                            |
-- |               <<<<<     FLASHBACK TECHNOLOGIES     >>>>>                   |
-- |                                                                            |
-- +============================================================================+

prompt <a name="flashback_database_info"></a>
prompt <font size="+2" face="Consolas" color="#336699"><b>数据库闪回</b></font></center><p> <hr align="left" width="600">
prompt <b><font face="Consolas" color="#990000">NOTE</font>: db_flashback_retention_target is specified in minutes; db_recovery_file_dest_size is specified in bytes  </font></b>
 
CLEAR COLUMNS COMPUTES
SET DEFINE OFF

 
COLUMN instance_name_print   FORMAT a95    HEADING 'Instance_Name'     ENTMAP OFF
COLUMN thread_number_print   FORMAT a95    HEADING 'Thread Number'     ENTMAP OFF
COLUMN name                  FORMAT a125   HEADING 'Name'              ENTMAP OFF
COLUMN value                               HEADING 'Value'             ENTMAP OFF
SET DEFINE ON 
-- BREAK ON report ON instance_name_print ON thread_number_print
 
SELECT '<div align="center"><font color="#336699"><b>' || I.INSTANCE_NAME ||
       '</b></font></div>' INSTANCE_NAME_PRINT,
       '<div align="center">' || I.THREAD# || '</div>' THREAD_NUMBER_PRINT,
       '<div nowrap>' || P.NAME || '</div>' NAME,
       (CASE P.NAME
         WHEN 'db_recovery_file_dest_size' THEN
          '<div nowrap align="right">' ||
          TO_CHAR(P.VALUE, '999,999,999,999,999') || '</div>'
         WHEN 'db_flashback_retention_target' THEN
          '<div nowrap align="right">' ||
          TO_CHAR(P.VALUE, '999,999,999,999,999') || '</div>'
         ELSE
          '<div nowrap align="right">' || NVL(P.VALUE, '(null)') ||
          '</div>'
       END) VALUE
  FROM GV$PARAMETER P, GV$INSTANCE I
 WHERE P.INST_ID = I.INST_ID
   AND P.NAME IN ('db_flashback_retention_target',
                  'db_recovery_file_dest_size',
                  'db_recovery_file_dest')
 ORDER BY 1, 3;

 
prompt <center>[<a class="noLink" href="#directory">回到目录</a>]</center><p>



-- +============================================================================+
-- |                                                                            |
-- |                      <<<<<     DG库情况     >>>>>                          |
-- |                                                                            |
-- +============================================================================+

host echo "      DG库. . ." 

prompt <a name="link_dg_config"></a>
prompt <font size="+2" face="Consolas" color="#336699"><b>DG相关的参数</b></font><hr align="left" width="600">

CLEAR COLUMNS COMPUTES
SET DEFINE OFF


COLUMN pname                FORMAT a75    HEADING '参数名称'    ENTMAP OFF
COLUMN instance_name_print  FORMAT a45    HEADING '实例名称'     ENTMAP OFF
COLUMN value                FORMAT a75    HEADING '参数值'             ENTMAP OFF

-- BREAK ON report ON pname

SELECT DECODE(p.isdefault,
              'FALSE',
              '<b><font color="#663300">' || SUBSTR(p.name, 0, 512) ||
              '</font></b>',
              '<b><font color="#336699">' || SUBSTR(p.name, 0, 512) ||
              '</font></b>') pname,
       DECODE(p.isdefault,
              'FALSE',
              '<font color="#663300"><b>' || i.instance_name ||
              '</b></font>',
              i.instance_name) instance_name_print,
       DECODE(p.isdefault,
              'FALSE',
              '<font color="#663300"><b>' || SUBSTR(p.value, 0, 512) ||
              '</b></font>',
              SUBSTR(p.value, 0, 512)) value
  FROM gv$parameter p, gv$instance i
 WHERE p.inst_id = i.inst_id
   AND p.name in ('dg_broker_start','db_name','db_unique_name','log_archive_config','log_archive_dest_1','log_archive_dest_2','log_archive_dest_state_1','log_archive_dest_state_2','log_archive_max_processes','remote_login_passwordfile','db_file_name_convert','log_file_name_convert','standby_file_management','fal_server','fal_client','dg_broker_config_file1','dg_broker_config_file2')
 ORDER BY p.name, i.instance_name;

prompt <center>[<a class="noLink" href="#directory">回到目录</a>]</center><p>





-- +----------------------------------------------------------------------------+
-- |                  - control_files CONFIGURATION -                           |
-- +----------------------------------------------------------------------------+

prompt <a name="control_files_all"></a>
prompt <font size="+2" face="Consolas" color="#336699"><b>● 控制文件(Control Files) </b></font><hr align="left" width="600">
 
prompt <a name="control_files"></a>

CLEAR COLUMNS COMPUTES
SET DEFINE OFF

 
COLUMN name                           HEADING 'Controlfile Name'  ENTMAP OFF
COLUMN status           FORMAT a75    HEADING 'Status'            ENTMAP OFF
COLUMN file_size        FORMAT a75    HEADING 'File Size'         ENTMAP OFF
 
SELECT C.NAME NAME,
       DECODE(C.STATUS,
              NULL,
              '<div align="center"><b><font color="darkgreen">VALID</font></b></div>',
              '<div align="center"><b><font color="#663300">' || C.STATUS ||
              '</font></b></div>') STATUS,
       '<div align="right">' ||
       TO_CHAR(BLOCK_SIZE * FILE_SIZE_BLKS, '999,999,999,999') || '</div>' FILE_SIZE
  FROM V$CONTROLFILE C
 ORDER BY C.NAME;


prompt <center>[<a class="noLink" href="#directory">回到目录</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                           - 表空间情况  -                                  |
-- +----------------------------------------------------------------------------+

host echo "            表空间情况. . ." 
prompt <a name="database_tablespace_qk"></a>
prompt <font size="+2" color="00CCFF"><b>表空间情况</b></font><hr align="left" width="800">
prompt <p>



prompt <a name="tablespaces_info"></a>
prompt <font size="+2" face="Consolas" color="#336699"><b>表空间状况</b></font> [<a class="noLink" href="#flash_usage">下一项</a>] <hr align="left" width="600">

CLEAR COLUMNS COMPUTES
SET DEFINE OFF


COLUMN status                                  HEADING '状态'            ENTMAP OFF
COLUMN name                                    HEADING '表空间名称'   ENTMAP OFF
COLUMN type        FORMAT a12                  HEADING '表空间类型'           ENTMAP OFF
COLUMN extent_mgt  FORMAT a12                  HEADING '扩展管理方式'         ENTMAP OFF
COLUMN segment_mgt FORMAT a12                   HEADING '段管理方式'         ENTMAP OFF
COLUMN ts_size     FORMAT 999,999,999,999,999  HEADING '表空间大小(MB)'   ENTMAP OFF
COLUMN free        FORMAT 999,999,999,999,999  HEADING '空闲(MB)'   ENTMAP OFF
COLUMN used        FORMAT 999,999,999,999,999  HEADING '使用(MB)'   ENTMAP OFF
COLUMN pct_used                                HEADING 'Pct. Used'         ENTMAP OFF
COLUMN BIGFILE        FORMAT a10  HEADING 'BIGFILE'   ENTMAP OFF
	

COMPUTE SUM label '<font color="#990000"><b>Total:</b></font>'   OF ts_size used free ON report

SELECT a.tablespace_name TS_NAME,
  round(total / (1024 * 1024 * 1024),6) TS_SIZE_G, 
  round(free / (1024 * 1024 * 1024),6) FREE_SIZE_G, 
  round((total - free) / (1024 * 1024 * 1024),6) USED_SIZE_G, 
  round((total - free) / total, 4) * 100 USED_PER
  FROM (
   select a.TABLESPACE_NAME,SUM(a.free) free from 
   (SELECT r.tablespace_name, SUM(r.bytes) free  FROM dba_free_space r  GROUP BY r.tablespace_name
  union
   select e.TABLESPACE_NAME, nvl(SUM(decode(e.AUTOEXTENSIBLE,'YES',e.MAXBYTES))-sum(decode(e.AUTOEXTENSIBLE,'YES',E.BYTES)),0) free from  dba_data_files e group by e.TABLESPACE_NAME ) a  
   group by  a.TABLESPACE_NAME  
  ) a, 
  (SELECT t.tablespace_name, SUM(decode(t.MAXBYTES,0,t.BYTES,t.MAXBYTES)) total 
  FROM dba_data_files  t
  GROUP BY t.tablespace_name) b 
  WHERE a.tablespace_name = b.tablespace_name
  order by 5 desc;
  

prompt <b><font face="Consolas" > 数据文件信息 </font></b>
CLEAR COLUMNS COMPUTES
SET DEFINE OFF

SELECT 
    ts.tablespace_name AS "TABLESPACE_NAME",
    ts.contents AS "CONTENTS",
    ts.extent_management AS "EXTENT_MANAGEMENT",
    COUNT(df.file_id) AS "TOTAL",
    COUNT(CASE WHEN UPPER(df.autoextensible) = 'YES' THEN 1 END) AS "AUTOFILES",
    ROUND((COUNT(CASE WHEN UPPER(df.autoextensible) = 'YES' THEN 1 END) * 100.0 / COUNT(df.file_id)), 2) AS "AUTORATIO(%)",
    ROUND(SUM(df.bytes) / 1024 / 1024 / 1024, 2) AS "TOTAL_GB",
    ROUND(SUM(CASE WHEN UPPER(df.autoextensible) = 'YES' THEN df.maxbytes ELSE df.bytes END) / 1024 / 1024 / 1024, 2) AS "MAX_GB"
FROM 
    dba_tablespaces ts
    JOIN dba_data_files df ON ts.tablespace_name = df.tablespace_name
GROUP BY 
    ts.tablespace_name, ts.contents, ts.extent_management
ORDER BY 7 DESC;

prompt <center>[<a class="noLink" href="#directory">回到目录</a>]</center>


prompt <a name="flash_usage"></a>
prompt <font size="+2" face="Consolas" color="#336699"><b> 数据库闪回空间使用情况</b></font><hr align="left" width="600">
prompt <font size="+1" face="Consolas" color="#336699"><b>● 数据库闪回空间总体使用情况</b></font>
CLEAR COLUMNS COMPUTES
SET DEFINE OFF


SELECT NAME,                    
       round(space_limit / 1024 / 1024 / 1024, 3) "LIMIT_GB",                   
       round(space_used / 1024 / 1024 / 1024, 3) "USED_GB",                   
       round(space_used / space_limit * 100, 3) "USED%",                    
       round(space_reclaimable / 1024 / 1024 / 1024, 3) "RECLAIM_GB",                   
       number_of_files                 
FROM   v$recovery_file_dest v 
WHERE v.SPACE_LIMIT<>0;


prompt <center>[<a class="noLink" href="#directory">回到目录</a>]</center>


prompt <a name="flash_usage_details"></a>
prompt <font size="+1" face="Consolas" color="#336699"><b>● 数据库闪回空间详细使用情况</b></font>
CLEAR COLUMNS COMPUTES
SET DEFINE OFF

SELECT nvl(frau.file_type,'<font color="#990000"><b>Total:</b></font>') file_type,
       sum(round(frau.percent_space_used / 100 * rfd.space_limit / 1024 / 1024 / 1024,3)) USED_GB,
       sum(frau.percent_space_used) percent_space_used,
       sum(frau.percent_space_reclaimable) percent_space_reclaimable,
       sum(round(frau.percent_space_reclaimable / 100 * rfd.space_limit / 1024 / 1024 / 1024,3)) RECLAIM_GB,
       sum(frau.number_of_files) number_of_files
FROM   v$flash_recovery_area_usage frau,
       v$recovery_file_dest rfd
 GROUP  BY ROLLUP(file_type);

prompt <center>[<a class="noLink" href="#directory">回到目录</a>]</center>
prompt <br/>



prompt <a name="ts_temp_usage"></a>
prompt <font size="+2" face="Consolas" color="#336699"><b> 临时表空间使用情况</b></font><hr align="left" width="600">
CLEAR COLUMNS COMPUTES
SET DEFINE OFF

select c.tablespace_name,
to_char(c.bytes/1024/1024/1024,'99,999.999') total_gb,
to_char( (c.bytes-d.bytes_used)/1024/1024/1024,'99,999.999') free_gb,
to_char(d.bytes_used/1024/1024/1024,'99,999.999') use_gb,
to_char(d.bytes_used*100/c.bytes,'99.99') || '%'use
from (select tablespace_name,sum(bytes) bytes
from dba_temp_files GROUP by tablespace_name) c,
(select tablespace_name,sum(bytes_cached) bytes_used
from v$temp_extent_pool GROUP by tablespace_name) d
where c.tablespace_name = d.tablespace_name;

prompt <center>[<a class="noLink" href="#directory">回到目录</a>]</center><p>


prompt <a name="ts_partition_usage"></a>
prompt <font size="+2" face="Consolas" color="#336699"><b> 分区使用情况</b></font><hr align="left" width="600">
CLEAR COLUMNS COMPUTES
SET DEFINE OFF

SELECT 
    p.table_owner AS "OWNER",
    p.table_name AS "TABLE_NAME",
    COUNT(p.partition_name) AS "TOTAL_PARTITION",
    MAX(p.partition_name) AS "MAX_PARTITION",
    MIN(p.partition_name) AS "MIN_PARTITION",
    SUM(s.bytes)/1024/1024 AS "TOTAL(MB)",
    ROUND(AVG(p.num_rows),0) AS "VAG_NUM_ROWS",
    MAX(p.num_rows) AS "MAX_NUM_ROWS",
    MIN(p.num_rows) AS "MIN_NUM_ROWS"
FROM dba_tab_partitions p
LEFT JOIN dba_segments s ON (p.partition_name = s.partition_name 
    AND p.table_owner = s.owner AND p.table_name = s.segment_name)
WHERE p.tablespace_name not in ('SYSTEM','SYSAUX')
and p.table_name not like 'BIN$%'
GROUP BY p.table_owner, p.table_name
ORDER BY 3 DESC;

prompt <center>[<a class="noLink" href="#directory">回到目录</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |                           - ASM磁盘监控  -                                 |
-- +----------------------------------------------------------------------------+
host echo "     ASM磁盘监控. . ." 

prompt <a name="database_asmdiskcheck"></a>
prompt <font size="+2" color="00CCFF"><b>ASM磁盘监控</b></font><hr align="left" width="800">
prompt <p>

prompt <a name="asm_disk"></a>
prompt <font size="+2" face="Consolas" color="#336699"><b>ASM磁盘</b></font> [<a class="noLink" href="#asm_diskgroup">下一项</a>] <hr align="left" width="600">


CLEAR COLUMNS COMPUTES
SET DEFINE OFF


--COMPUTE SUM label '<font color="#990000"><b>Total:</b></font>'   OF TOTAL_MB FREE_MB   ON report

SELECT a.GROUP_NUMBER,
       a.DISK_NUMBER,
       a.NAME,
       a.path,
       a.STATE,
       a.MOUNT_STATUS,
       a.TOTAL_MB,
       a.FREE_MB,
       a.CREATE_DATE,
       a.MOUNT_DATE,
       a.LIBRARY
       FROM V$ASM_DISK a
 ORDER BY a.GROUP_NUMBER, a.DISK_NUMBER;

prompt <center>[<a class="noLink" href="#directory">回到目录</a>]</center><p>


prompt <a name="asm_diskgroup"></a>
prompt <font size="+2" face="Consolas" color="#336699"><b>ASM磁盘组使用情况</b></font><hr align="left" width="600">

CLEAR COLUMNS COMPUTES
SET DEFINE OFF

--COMPUTE SUM label '<font color="#990000"><b>Total:</b></font>'   OF TOTAL_MB FREE_MB   ON report
SELECT di.GROUP_NUMBER,
       di.NAME,
       di.BLOCK_SIZE,
       di.STATE,
       di.TYPE,
       di.TOTAL_MB,
       di.FREE_MB,
       di.COMPATIBILITY,
       round((total_mb-free_mb)/total_mb*100,2)||'%' as used_pct,
       di.OFFLINE_DISKS
  FROM v$asm_diskgroup di
 ORDER BY di.GROUP_NUMBER;


prompt <center>[<a class="noLink" href="#directory">回到目录</a>]</center><p>

prompt <a name="asm_diskgroupinstance"></a>
prompt <font size="+2" face="Consolas" color="#336699"><b>ASM实例</b></font><hr align="left" width="600">

CLEAR COLUMNS COMPUTES
SET DEFINE OFF

SELECT * FROM v$asm_client;

prompt <center>[<a class="noLink" href="#directory">回到目录</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |                           - 其他情况  -                                    |
-- +----------------------------------------------------------------------------+
host echo "     其他情况. . ." 

prompt <a name="other_situations"></a>
prompt <font size="+2" color="00CCFF"><b>其他</b></font><hr align="left" width="800">
prompt <p>

-- +----------------------------------------------------------------------------+
-- |                           - 并行  -                                        |
-- +----------------------------------------------------------------------------+

host echo 并行度....

prompt <a name="parallel_check"></a>
prompt <font size="+2" face="Consolas" color="#336699"><b>并行度检查</b></font><hr align="left" width="600">

prompt <b><font face="Consolas" > 表带有并行度 </font></b>
CLEAR COLUMNS COMPUTES
SET DEFINE OFF

SELECT t.owner, t.table_name, degree
  FROM dba_tables t
where (t.degree >'1' or t.degree='DEFAULT')
AND owner NOT IN ('SYS','SYSTEM','PUBLIC','MDSYS','TSMSYS','DMSYS','DBSNMP','SCOTT','DB_MONITOR','OUTLN','MGMT_VIEW','FLOWS_FILES','ORDSYS','EXFSYS','WMSYS','APPQOSSYS','APEX_030200','APEX_050000','OWBSYS_AUDIT','ORDDATA','CTXSYS','ANONYMOUS','SYSMAN','XDB','ORDPLUGINS','OWBSYS','SI_INFORMTN_SCHEMA','OLAPSYS','ORACLE_OCM','XS$NULL','BI','PM','MDDATA','IX','SH','DIP','OE','APEX_PUBLIC_USER','HR','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','APEX_040200','DVSYS','LBACSYS','GSMADMIN_INTERNAL','AUDSYS','OJVMSYS','SYS$UMF','GGSYS','DBSFWUSER','DVF','GSMCATUSER','SYSBACKUP','REMOTE_SCHEDULER_AGENT','GSMUSER','SYSRAC','SYSKM','SYSDG','PDBADMIN','WKSYS','GSMROOTUSER')
order by t.owner, t.table_name;


prompt <b><font face="Consolas" > 索引带有并行度 </font></b>

CLEAR COLUMNS COMPUTES
SET DEFINE OFF


SELECT t.owner, t.table_name, index_name, degree, status
  FROM dba_indexes t
where (t.degree >'1' or t.degree='DEFAULT')
AND owner NOT IN ('SYS','SYSTEM','PUBLIC','MDSYS','TSMSYS','DMSYS','DBSNMP','SCOTT','DB_MONITOR','OUTLN','MGMT_VIEW','FLOWS_FILES','ORDSYS','EXFSYS','WMSYS','APPQOSSYS','APEX_030200','APEX_050000','OWBSYS_AUDIT','ORDDATA','CTXSYS','ANONYMOUS','SYSMAN','XDB','ORDPLUGINS','OWBSYS','SI_INFORMTN_SCHEMA','OLAPSYS','ORACLE_OCM','XS$NULL','BI','PM','MDDATA','IX','SH','DIP','OE','APEX_PUBLIC_USER','HR','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','APEX_040200','DVSYS','LBACSYS','GSMADMIN_INTERNAL','AUDSYS','OJVMSYS','SYS$UMF','GGSYS','DBSFWUSER','DVF','GSMCATUSER','SYSBACKUP','REMOTE_SCHEDULER_AGENT','GSMUSER','SYSRAC','SYSKM','SYSDG','PDBADMIN','WKSYS','GSMROOTUSER')
order by  t.owner, t.table_name;

prompt <center>[<a class="noLink" href="#directory">回到目录</a>]</center><p>



-- +----------------------------------------------------------------------------+
-- |                           - 用户安全  -                                      |
-- +----------------------------------------------------------------------------+

host echo 用户安全....

prompt <a name="user_secure"></a>
prompt <font size="+2" face="Consolas" color="#336699"><b>用户安全</b></font><hr align="left" width="600">

prompt <b><font face="Consolas" > 数据库用户一览 </font></b>
CLEAR COLUMNS COMPUTES
SET DEFINE OFF
COLUMN username              FORMAT a75    HEAD 'Username'        ENTMAP OFF
COLUMN account_status        FORMAT a75    HEAD 'Account Status'  ENTMAP OFF
COLUMN expiry_date           FORMAT a75    HEAD 'Expire Date'     ENTMAP OFF
COLUMN default_tablespace    FORMAT a75    HEAD 'Default Tbs.'    ENTMAP OFF
COLUMN temporary_tablespace  FORMAT a75    HEAD 'Temp Tbs.'       ENTMAP OFF
COLUMN CREATED               FORMAT a75    HEAD 'CREATED On'      ENTMAP OFF
COLUMN profile               FORMAT a75    HEAD 'Profile'         ENTMAP OFF
COLUMN sysdba                FORMAT a75    HEAD 'SYSDBA'          ENTMAP OFF
COLUMN sysoper               FORMAT a75    HEAD 'SYSOPER'         ENTMAP OFF
COLUMN is_oracle_internal_user               FORMAT a25    HEAD 'is_oracle_internal_user'         ENTMAP OFF
SET DEFINE ON


SELECT '<b><font color="#336699">' || A.USERNAME || '</font></b>' USERNAME,
       DECODE(A.ACCOUNT_STATUS,
              'OPEN',
              '<div align="left"><b><font color="darkgreen">' ||
              A.ACCOUNT_STATUS || '</font></b></div>',
              '<div align="left"><b><font color="#663300">' ||
              A.ACCOUNT_STATUS || '</font></b></div>') ACCOUNT_STATUS,
       '<div nowrap align="right">' ||
       NVL(TO_CHAR(A.EXPIRY_DATE, 'yyyy-mm-dd HH24:MI:SS'), '<br>') ||
       '</div>' EXPIRY_DATE,
       A.DEFAULT_TABLESPACE DEFAULT_TABLESPACE,
       A.TEMPORARY_TABLESPACE TEMPORARY_TABLESPACE,
       '<div nowrap align="right">' ||
       TO_CHAR(A.CREATED, 'yyyy-mm-dd HH24:MI:SS') || '</div>' CREATED,
       A.PROFILE PROFILE,
       '<div nowrap align="center">' ||
       NVL(DECODE(P.SYSDBA, 'TRUE', 'TRUE', ''), '<br>') || '</div>' SYSDBA,
       '<div nowrap align="center">' ||
       NVL(DECODE(P.SYSOPER, 'TRUE', 'TRUE', ''), '<br>') || '</div>' SYSOPER
  FROM DBA_USERS A, V$PWFILE_USERS P 
 WHERE  A.USERNAME = P.USERNAME(+)
 ORDER BY A.ACCOUNT_STATUS;

prompt <center>[<a class="noLink" href="#directory">回到目录</a>]</center><p>


prompt <b><font face="Consolas" > 拥有DBA角色的用户 </font></b>

CLEAR COLUMNS COMPUTES
SET DEFINE OFF
COLUMN grantee        FORMAT a70   HEADING 'Grantee'         ENTMAP OFF
COLUMN granted_role   FORMAT a35   HEADING 'Granted Role'    ENTMAP OFF
COLUMN admin_option   FORMAT a75   HEADING 'Admin. Option?'  ENTMAP OFF
COLUMN default_role   FORMAT a75   HEADING 'Default Role?'   ENTMAP OFF
SET DEFINE ON

SELECT '<b><font color="#336699">' || grantee || '</font></b>' grantee,
       '<div align="center">' || granted_role || '</div>' granted_role,
       DECODE(admin_option,
              'YES',
              '<div align="center"><font color="darkgreen"><b>' ||
              admin_option || '</b></font></div>',
              'NO',
              '<div align="center"><font color="#990000"><b>' ||
              admin_option || '</b></font></div>',
              '<div align="center"><font color="#663300"><b>' ||
              admin_option || '</b></font></div>') admin_option,
       DECODE(default_role,
              'YES',
              '<div align="center"><font color="darkgreen"><b>' ||
              default_role || '</b></font></div>',
              'NO',
              '<div align="center"><font color="#990000"><b>' ||
              default_role || '</b></font></div>',
              '<div align="center"><font color="#663300"><b>' ||
              default_role || '</b></font></div>') default_role
  FROM dba_role_privs d
 WHERE granted_role = 'DBA'
 ORDER BY grantee, granted_role;

prompt <center>[<a class="noLink" href="#directory">回到目录</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |                           - 性能分析  -                                      |
-- +----------------------------------------------------------------------------+

host echo 性能分析....


prompt <a name="performance_info"></a>
prompt <font size="+2" face="Consolas" color="#336699"><b>性能分析</b></font><hr align="left" width="600">

prompt <b><font face="Consolas" > 天别AAS信息 </font></b>

CLEAR COLUMNS COMPUTES
SET DEFINE OFF

SELECT 
    TRUNC(BEGIN_TIME) AS STAT_DATE,
    COUNT(*) AS SNAPSHOT_COUNT,
    ROUND(SUM("DB TIME"), 2) AS TOTAL_DB_TIME_MIN,
    ROUND(SUM(ELAPSED_MINUTES), 2) AS TOTAL_ELAPSED_MIN,
    ROUND(SUM("DB TIME") / SUM(ELAPSED_MINUTES), 4) AS DAILY_AVG_AAS
FROM (
    SELECT 
        INSTANCE_NUMBER,
        SNAP_ID,
        BEGIN_TIME,
        END_TIME,
        "DB TIME",
        ROUND(EXTRACT(DAY FROM ELAPSED_INTERVAL) * 24 * 60 +
              EXTRACT(HOUR FROM ELAPSED_INTERVAL) * 60 +
              EXTRACT(MINUTE FROM ELAPSED_INTERVAL) +
              EXTRACT(SECOND FROM ELAPSED_INTERVAL) / 60, 2) AS ELAPSED_MINUTES
    FROM (
        SELECT 
            A.INSTANCE_NUMBER,
            A.SNAP_ID,
            B.BEGIN_INTERVAL_TIME + 0 BEGIN_TIME,
            B.END_INTERVAL_TIME + 0 END_TIME,
            (B.END_INTERVAL_TIME - B.BEGIN_INTERVAL_TIME) AS ELAPSED_INTERVAL,
            ROUND((VALUE - LAG(VALUE, 1, NULL) OVER (ORDER BY A.INSTANCE_NUMBER, A.SNAP_ID)), 2) AS "DB TIME"
        FROM (
            SELECT 
                B.SNAP_ID,
                INSTANCE_NUMBER,
                SUM(VALUE) / 1000000 / 60 VALUE
            FROM DBA_HIST_SYS_TIME_MODEL B
            WHERE B.DBID = (SELECT DBID FROM V$DATABASE)
                AND UPPER(B.STAT_NAME) = UPPER('DB time')
            GROUP BY B.SNAP_ID, INSTANCE_NUMBER
        ) A,
        DBA_HIST_SNAPSHOT B
        WHERE A.SNAP_ID = B.SNAP_ID
            AND B.DBID = (SELECT DBID FROM V$DATABASE)
            AND B.INSTANCE_NUMBER = A.INSTANCE_NUMBER
    )
    WHERE BEGIN_TIME >= TRUNC(SYSDATE - 15)
        AND "DB TIME" > 0
)
GROUP BY TRUNC(BEGIN_TIME)
ORDER BY STAT_DATE DESC;

prompt <center>[<a class="noLink" href="#directory">回到目录</a>]</center>


-- +----------------------------------------------------------------------------+
-- |                           - job运行  -                                     |
-- +----------------------------------------------------------------------------+

host echo job运行....


prompt <a name="scheduler_jobs"></a>
prompt <font size="+2" face="Consolas" color="#336699"><b>scheduler_jobs运行状况</b></font> [<a class="noLink" href="#jobs_info">下一项</a>] <hr align="left" width="600">
CLEAR COLUMNS COMPUTES
SET DEFINE OFF

	
COLUMN is_running  FORMAT a10    HEADING 'is_running'  ENTMAP OFF
COLUMN REPEAT_INTERVAL  FORMAT a140    HEADING '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;REPEAT_INTERVAL&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'  ENTMAP OFF
COLUMN start_date   FORMAT a140    HEADING '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;START_DATE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'  ENTMAP OFF
COLUMN end_date     FORMAT a140    HEADING '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;END_DATE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'  ENTMAP OFF
COLUMN NEXT_RUN_DATE     FORMAT a140    HEADING '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;NEXT_RUN_DATE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'  ENTMAP OFF	
COLUMN last_start_date   FORMAT a140    HEADING '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LAST_START_DATE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'  ENTMAP OFF
COLUMN LAST_RUN_DURATION   FORMAT a140    HEADING '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LAST_RUN_DURATION&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'  ENTMAP OFF
COLUMN comments  FORMAT a180    HEADING '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;job_comments&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'  ENTMAP OFF
SET DEFINE ON

SELECT j.JOB_CREATOR,
       j.OWNER,
       j.job_name,
       j.state job_STATE,
       DECODE(J.STATE, 'RUNNING', 'Y', 'N') is_running,
       j.job_type,
       j.job_action,
       --j.JOB_STYLE,
       j.PROGRAM_OWNER,
       j.PROGRAM_NAME,
       j.schedule_type,
       j.repeat_interval,
       TO_CHAR(j.start_date, 'YYYY-MM-DD HH24:mi:ss') start_date,
       TO_CHAR(j.end_date, 'YYYY-MM-DD HH24:mi:ss') end_date,
       TO_CHAR(J.NEXT_RUN_DATE, 'YYYY-MM-DD HH24:mi:ss') NEXT_RUN_DATE,
       TO_CHAR(J.last_start_date, 'YYYY-MM-DD HH24:mi:ss') last_start_date,
       (J.LAST_RUN_DURATION) LAST_RUN_DURATION,
       j.run_count,
       j.NUMBER_OF_ARGUMENTS,
       j.ENABLED,
       j.AUTO_DROP,
       j.comments
  FROM dba_scheduler_jobs j
  where j.owner not in ('SYS','SYSTEM','PUBLIC','MDSYS','TSMSYS','DMSYS','DBSNMP','SCOTT','DB_MONITOR','OUTLN','MGMT_VIEW','FLOWS_FILES','ORDSYS','EXFSYS','WMSYS','APPQOSSYS','APEX_030200','APEX_050000','OWBSYS_AUDIT','ORDDATA','CTXSYS','ANONYMOUS','SYSMAN','XDB','ORDPLUGINS','OWBSYS','SI_INFORMTN_SCHEMA','OLAPSYS','ORACLE_OCM','XS$NULL','BI','PM','MDDATA','IX','SH','DIP','OE','APEX_PUBLIC_USER','HR','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','APEX_040200','DVSYS','LBACSYS','GSMADMIN_INTERNAL','AUDSYS','OJVMSYS','SYS$UMF','GGSYS','DBSFWUSER','DVF','GSMCATUSER','SYSBACKUP','REMOTE_SCHEDULER_AGENT','GSMUSER','SYSRAC','SYSKM','SYSDG','PDBADMIN','WKSYS','GSMROOTUSER');


prompt <center>[<a class="noLink" href="#directory">回到目录</a>]</center>

prompt <a name="jobs_info"></a>
prompt <font size="+2" face="Consolas" color="#336699"><b>jobs运行状况</b></font> [<a class="noLink" href="#awr_new_lastone_link">下一项</a>] <hr align="left" width="600">

CLEAR COLUMNS COMPUTES
SET DEFINE OFF


COLUMN job_id     FORMAT a75             HEADING '作业ID'           ENTMAP OFF
COLUMN username   FORMAT a75             HEADING '用户'             ENTMAP OFF
COLUMN what       FORMAT a100            HEADING '作业内容'             ENTMAP OFF
COLUMN next_date   FORMAT a140    HEADING '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;下一次运行时间&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'  ENTMAP OFF
COLUMN interval   FORMAT a100             HEADING '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;间隔&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' ENTMAP OFF
COLUMN last_date   FORMAT a140    HEADING '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;上一次运行时间&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'  ENTMAP OFF
COLUMN failures   FORMAT a75             HEADING '失败次数'         ENTMAP OFF
COLUMN broken     FORMAT a75             HEADING '是否损坏'          ENTMAP OFF

SET DEFINE ON


SELECT 
       DECODE(broken,
              'Y',
              '<b><font color="#990000"><div align="center">' || job ||
              '</div></font></b>',
              '<b><font color="#336699"><div align="center">' || job ||
              '</div></font></b>') job_id,
       DECODE(broken,
              'Y',
              '<b><font color="#990000">' || log_user || '</font></b>',
              log_user) username,
       DECODE(broken,
              'Y',
              '<b><font color="#990000">' || what || '</font></b>',
              what) what,
       DECODE(broken,
              'Y',
              '<div nowrap align="right"><b><font color="#990000">' ||
              NVL(TO_CHAR(next_date, 'yyyy-mm-dd HH24:MI:SS'), '<br>') ||
              '</font></b></div>',
              '<div nowrap align="right">' ||
              NVL(TO_CHAR(next_date, 'yyyy-mm-dd HH24:MI:SS'), '<br>') ||
              '</div>') next_date,
       DECODE(broken,
              'Y',
              '<b><font color="#990000">' || interval || '</font></b>',
              interval) interval,
       DECODE(broken,
              'Y',
              '<div nowrap align="right"><b><font color="#990000">' ||
              NVL(TO_CHAR(last_date, 'yyyy-mm-dd HH24:MI:SS'), '<br>') ||
              '</font></b></div>',
              '<div nowrap align="right">' ||
              NVL(TO_CHAR(last_date, 'yyyy-mm-dd HH24:MI:SS'), '<br>') ||
              '</div>') last_date,
       DECODE(broken,
              'Y',
              '<b><font color="#990000"><div align="center">' ||
              NVL(failures, 0) || '</div></font></b>',
              '<div align="center">' || NVL(failures, 0) || '</div>') failures,
       DECODE(broken,
              'Y',
              '<b><font color="#990000"><div align="center">' || broken ||
              '</div></font></b>',
              '<div align="center">' || broken || '</div>') broken
  FROM dba_jobs d
 ORDER BY d.broken, d.JOB;

prompt <center>[<a class="noLink" href="#directory">回到目录</a>]</center>


host echo 生成最新的一次AWR报告....

-------------------------------------------------------------------------------------------------------------------------
------------------------------   生成最新的一次AWR报告  ------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------

set termout       off
set echo          off
set feedback      off
set verify        off
set wrap          on
set trimspool     on
set serveroutput  off
set escape        off
set sqlblanklines off

  

SET MARKUP HTML OFF PREFORMAT OFF entmap on



 
set linesize 4000 ;
set pagesize 0 ;
set newpage 1 ;
set feed off;
set heading off



prompt <hr>
prompt <hr>
prompt <a name="awr_new_lastone_link"></a>
prompt <font size="+1" face="Consolas" color="#336699"><b>● 最新的一次AWR报告  [<a class="noLink" href="#html_bottom_link">转到页底</a>] [<a class="noLink" href="#directory">回到目录</a>]</b></font><hr align="left" width="800">



prompt <b><font face="Consolas" color="#990000">NOTE</font>: SQL脚本 ： SELECT * FROM table(dbms_workload_repository.awr_report_html(&_dbid,&_instance_number,&_snap_id,&_snap_id1));  </font></b>
prompt 　　 　　 　　 　　



SELECT * FROM table(dbms_workload_repository.awr_report_html(&_dbid,&_instance_number,&_snap_id,&_snap_id1));

prompt 　　 　　 　　 　　

prompt <center>[<a class="noLink" href="#directory">回到目录</a>][<a class="noLink" href="#awr_new_lastone_link">回到AWR</a>]</center><p>



host echo 数据库脚本执行结束....

-------------------------------------------------------------------------------------------------------------------------
------------------------------   报告结束  ------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------


COLUMN date_time_end NEW_VALUE _date_time_end NOPRINT
SELECT TO_CHAR(SYSDATE,'YYYY-MM-DD HH24:MI:SS') date_time_end FROM dual;



prompt <font size=+2 color=darkgreen><b></b></font><hr>
prompt <center><font size="+2" face="Consolas" color="#663300"><b>数据库巡检服务报告结束</b></font></center>

prompt
prompt <b><font face="Consolas" color="#990000">NOTE</font>: 结束时间：&_date_time_end </font> </b>
prompt

prompt <a name="html_bottom_link"></a>
prompt <center>[<a class="noLink" href="#directory">回到目录</a>]</center><p>

prompt 
prompt 巡检报告生成到当前目录下: &_reporttitle..html
prompt 巡检脚本执行结束！
exit
EXIT
