--sqlserver  日常检查脚本
print '----------------------------'
print ' 0.sqlserver all information  '
print '----------------------------'
print '                             '
print '*********************************'

--Step 1: Setting NULLs and quoted identifiers to ON and checking the version of SQL Server 
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'prodver') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)                        
drop table prodver
create table prodver ([index] int, Name nvarchar(50),Internal_value int, Charcater_Value nvarchar(50))
insert into prodver exec xp_msver 'ProductVersion'
if (select substring(Charcater_Value,1,1)from prodver)!=8
begin

                   
-- Step 2: This code will be used if the instance is Not SQL Server 2000 


Declare @image_path nvarchar(100)                        
Declare @startup_type int                        
Declare @startuptype nvarchar(100)                        
Declare @start_username nvarchar(100)                        
Declare @instance_name nvarchar(100)                        
Declare @system_instance_name nvarchar(100)                        
Declare @log_directory nvarchar(100)                        
Declare @key nvarchar(1000)                        
Declare @registry_key nvarchar(100)                        
Declare @registry_key1 nvarchar(300)                        
Declare @registry_key2 nvarchar(300)                        
Declare @IpAddress nvarchar(20)                        
Declare @domain nvarchar(50)                        
Declare @cluster int                        
Declare @instance_name1 nvarchar(100)                        
-- Step 3: Reading registry keys for IP,Binaries,Startup type ,startup username, errorlogs location and domain.
SET @instance_name = coalesce(convert(nvarchar(100), serverproperty('InstanceName')),'MSSQLSERVER');                        
If @instance_name!='MSSQLSERVER'                        
Set @instance_name=@instance_name                       
 
    Set @instance_name1= coalesce(convert(nvarchar(100), serverproperty('InstanceName')),'MSSQLSERVER');                        
If @instance_name1!='MSSQLSERVER'                        
Set @instance_name1='MSSQL$'+@instance_name1                        
EXEC master.dbo.xp_regread N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\Microsoft SQL Server\Instance Names\SQL', @instance_name, @system_instance_name output;                        
                        
Set @key=N'SYSTEM\CurrentControlSet\Services\' +@instance_name1;                        
SET @registry_key = N'Software\Microsoft\Microsoft SQL Server\' + @system_instance_name + '\MSSQLServer\Parameters';                        
If @registry_key is NULL                        
set @instance_name=coalesce(convert(nvarchar(100), serverproperty('InstanceName')),'MSSQLSERVER');                        
EXEC master.dbo.xp_regread N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\Microsoft SQL Server\Instance Names\SQL', @instance_name, @system_instance_name output;                        


SET @registry_key = N'Software\Microsoft\Microsoft SQL Server\' + @system_instance_name + '\MSSQLServer\Parameters';                        
SET @registry_key1 = N'Software\Microsoft\Microsoft SQL Server\' + @system_instance_name + '\MSSQLServer\supersocketnetlib\TCP\IP1';                        
SET @registry_key2 = N'SYSTEM\ControlSet001\Services\Tcpip\Parameters\';                        
                        
EXEC master.dbo.xp_regread 'HKEY_LOCAL_MACHINE',@key,@value_name='ImagePath',@value=@image_path OUTPUT                        
EXEC master.dbo.xp_regread 'HKEY_LOCAL_MACHINE',@key,@value_name='Start',@value=@startup_type OUTPUT                        
EXEC master.dbo.xp_regread 'HKEY_LOCAL_MACHINE',@key,@value_name='ObjectName',@value=@start_username OUTPUT                        
EXEC master.dbo.xp_regread 'HKEY_LOCAL_MACHINE',@registry_key,@value_name='SQLArg1',@value=@log_directory OUTPUT                        
EXEC master.dbo.xp_regread 'HKEY_LOCAL_MACHINE',@registry_key1,@value_name='IpAddress',@value=@IpAddress OUTPUT                        
EXEC master.dbo.xp_regread 'HKEY_LOCAL_MACHINE',@registry_key2,@value_name='Domain',@value=@domain OUTPUT                        
                        
Set @startuptype= 
(select 'Start Up Mode' =                        
CASE                        
WHEN @startup_type=2 then 'AUTOMATIC'                        
WHEN @startup_type=3 then 'MANUAL'                        
WHEN @startup_type=4 then 'Disabled'                        
END)                        
                        
--Step 4: Getting the cluster node names if the server is on cluster .else this value will be NULL.


declare @Out nvarchar(400)                        
SELECT @Out = COALESCE(@Out+'' ,'') + Nodename                        
from sys.dm_os_cluster_nodes                        
                        
-- Step 5: printing Server details 
                        
SELECT                       
@domain as 'Domain',                      
serverproperty('ComputerNamePhysicalNetBIOS') as 'MachineName',                      
CPU_COUNT as 'CPUCount',
(physical_memory_in_bytes/1048576) as 'PhysicalMemoryMB',                      
@Ipaddress as 'IP_Address',                      
@instance_name1 as 'InstanceName',
@image_path as 'BinariesPath',                      
@log_directory as 'ErrorLogsLocation',                      
@start_username as 'StartupUser',                      
@Startuptype as 'StartupType',                      
serverproperty('Productlevel') as 'ServicePack',                      
serverproperty('edition') as 'Edition',                      
serverproperty('productversion') as 'Version',                      
serverproperty('collation') as 'Collation',                      
serverproperty('Isclustered') as 'ISClustered',                      
@out as 'ClusterNodes',                      
serverproperty('IsFullTextInstalled') as 'ISFullText'                       
From sys.dm_os_sys_info                         
                      


-- Step 6: Printing database details 

SELECT                       
serverproperty ('ComputerNamePhysicalNetBIOS') as 'Machine'                      
,@instance_name1 as InstanceName,                      
(SELECT 'file_type' =                      
CASE                      
WHEN s.groupid <> 0 THEN 'data'                      
WHEN s.groupid = 0 THEN 'log'                      
END) AS 'fileType'                      
, d.dbid as 'DBID'                      
, d.name AS 'DBName'                      
, s.name AS 'LogicalFileName'                      
, s.filename AS 'PhysicalFileName'                      
  , (s.size * 8 / 1024) AS 'FileSizeMB' -- file size in MB                      
  , d.cmptlevel as 'CompatibilityLevel'                      
  , DATABASEPROPERTYEX (d.name,'Recovery') as 'RecoveryModel'                      
  , DATABASEPROPERTYEX (d.name,'Status') as 'DatabaseStatus' ,                     
  --, d.is_published as 'Publisher'                      
  --, d.is_subscribed as 'Subscriber'                      
  --, d.is_distributor as 'Distributor' 
  (SELECT 'is_replication' =                      
CASE                      
WHEN d.category = 1 THEN 'Published'                      
WHEN d.category = 2 THEN 'subscribed'                      
WHEN d.category = 4 THEN 'Merge published'
WHEN d.category = 8 THEN 'merge subscribed'
Else 'NO replication'
END) AS 'Is_replication'                      
  , m.mirroring_state as 'MirroringState'                      
--INTO master.[dbo].[databasedetails]                      
FROM                      
sys.sysdatabases d INNER JOIN sys.sysaltfiles s                      
ON                      
d.dbid=s.dbid                      
INNER JOIN sys.database_mirroring m                      
ON                      
d.dbid=m.database_id                      
ORDER BY                      
d.name                      
          
          
--Step 7 :printing Backup details                       

Select distinct                             
b.machine_name as 'ServerName',                        
b.server_name as 'InstanceName',                        
b.database_name as 'DatabaseName',                            
d.database_id 'DBID',                            
CASE b.[type]                                  
WHEN 'D' THEN 'Full'                                  
WHEN 'I' THEN 'Differential'                                  
WHEN 'L' THEN 'Transaction Log'                                  
END as 'BackupType'                                 
--INTO [dbo].[backupdetails]                        
from sys.databases d inner join msdb.dbo.backupset b                            
On b.database_name =d.name                        

End
else

begin

--Step 8: If the instance is 2000 this code will be used.

declare @registry_key4 nvarchar(100)                        
declare @Host_Name varchar(100)
declare @CPU varchar(3)
declare @nodes nvarchar(400)
set @nodes =null /* We are not able to trap the node names for SQL Server 2000 so far*/
declare @mirroring varchar(15)
set @mirroring ='NOT APPLICABLE' /*Mirroring does not exist in SQL Server 2000*/
Declare @reg_node1 varchar(100)
Declare @reg_node2 varchar(100)
Declare @reg_node3 varchar(100)
Declare @reg_node4 varchar(100)
 
SET @reg_node1 = N'Cluster\Nodes\1'
SET @reg_node2 = N'Cluster\Nodes\2'
SET @reg_node3 = N'Cluster\Nodes\3'
SET @reg_node4 = N'Cluster\Nodes\4'
 
Declare @image_path1 varchar(100)
Declare @image_path2 varchar(100)
Declare @image_path3 varchar(100)
Declare @image_path4 varchar(100)

set @image_path1=null
set @image_path2=null
set @image_path3=null
set @image_path4=null


Exec master.dbo.xp_regread 'HKEY_LOCAL_MACHINE',@reg_node1, @value_name='NodeName',@value=@image_path1 OUTPUT
Exec master.dbo.xp_regread 'HKEY_LOCAL_MACHINE',@reg_node2, @value_name='NodeName',@value=@image_path2 OUTPUT
Exec master.dbo.xp_regread 'HKEY_LOCAL_MACHINE',@reg_node3, @value_name='NodeName',@value=@image_path3 OUTPUT
Exec master.dbo.xp_regread 'HKEY_LOCAL_MACHINE',@reg_node4, @value_name='NodeName',@value=@image_path4 OUTPUT

    IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'nodes') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)                        
drop table nodes
Create table nodes (name varchar (20))
 insert into nodes values (@image_path1)
 insert into nodes values (@image_path2)
 insert into nodes values (@image_path3)
 insert into nodes values (@image_path4)
 --declare @Out nvarchar(400)                        
 --declare @value nvarchar (20)
 SELECT @Out = COALESCE(@Out+'/' ,'') + name from nodes where name is not null
   
-- Step 9: Reading registry keys for Number of CPUs,Binaries,Startup type ,startup username, errorlogs location and domain.

SET @instance_name = coalesce(convert(nvarchar(100), serverproperty('InstanceName')),'MSSQLSERVER');
IF @instance_name!='MSSQLSERVER'


BEGIN
set @system_instance_name=@instance_name
set @instance_name='MSSQL$'+@instance_name


SET @key=N'SYSTEM\CurrentControlSet\Services\' +@instance_name;
SET @registry_key = N'Software\Microsoft\Microsoft SQL Server\' + @system_instance_name + '\MSSQLServer\Parameters';
SET @registry_key1 = N'Software\Microsoft\Microsoft SQL Server\' + @system_instance_name + '\Setup';
SET @registry_key2 = N'SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\';
SET @registry_key4 = N'SYSTEM\CurrentControlSet\Control\Session Manager\Environment'



EXEC master.dbo.xp_regread 'HKEY_LOCAL_MACHINE',@registry_key1,@value_name='SQLPath',@value=@image_path OUTPUT
EXEC master.dbo.xp_regread 'HKEY_LOCAL_MACHINE',@key,@value_name='Start',@value=@startup_type OUTPUT
EXEC master.dbo.xp_regread 'HKEY_LOCAL_MACHINE',@key,@value_name='ObjectName',@value=@start_username OUTPUT
EXEC master.dbo.xp_regread 'HKEY_LOCAL_MACHINE',@registry_key,@value_name='SQLArg1',@value=@log_directory OUTPUT
EXEC master.dbo.xp_regread 'HKEY_LOCAL_MACHINE',@registry_key2,@value_name='Domain',@value=@domain OUTPUT
EXEC master.dbo.xp_regread 'HKEY_LOCAL_MACHINE',@registry_key4,@value_name='NUMBER_OF_PROCESSORS',@value=@CPU OUTPUT                        

END

IF @instance_name='MSSQLSERVER'
BEGIN
SET @key=N'SYSTEM\CurrentControlSet\Services\' +@instance_name;
SET @registry_key = N'Software\Microsoft\MSSQLSERVER\MSSQLServer\Parameters';
SET @registry_key1 = N'Software\Microsoft\MSSQLSERVER\Setup';
SET @registry_key2 = N'SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\';
SET @registry_key4 = N'SYSTEM\CurrentControlSet\Control\Session Manager\Environment'                                              

EXEC master.dbo.xp_regread 'HKEY_LOCAL_MACHINE',@registry_key1,@value_name='SQLPath',@value=@image_path OUTPUT
EXEC master.dbo.xp_regread 'HKEY_LOCAL_MACHINE',@key,@value_name='Start',@value=@startup_type OUTPUT
EXEC master.dbo.xp_regread 'HKEY_LOCAL_MACHINE',@key,@value_name='ObjectName',@value=@start_username OUTPUT
EXEC master.dbo.xp_regread 'HKEY_LOCAL_MACHINE',@registry_key,@value_name='SQLArg1',@value=@log_directory OUTPUT
--EXEC master.dbo.xp_regread 'HKEY_LOCAL_MACHINE',@registry_key1,@value_name='IpAddress',@value=@IpAddress OUTPUT
EXEC master.dbo.xp_regread 'HKEY_LOCAL_MACHINE',@registry_key2,@value_name='Domain',@value=@domain OUTPUT
EXEC master.dbo.xp_regread 'HKEY_LOCAL_MACHINE',@registry_key4,@value_name='NUMBER_OF_PROCESSORS',@value=@CPU OUTPUT                        


END
set @startuptype= (select 'Start Up Mode' =
CASE
WHEN @startup_type=2 then 'AUTOMATIC'
WHEN @startup_type=3 then 'MANUAL'
WHEN @startup_type=4 then 'Disabled'
END)


--Step 10 : Using ipconfig and xp_msver to get physical memory and IP


IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'tmp') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)                      
DROP TABLE tmp
create table tmp (server varchar(100)default cast( serverproperty ('Machinename') as varchar),[index] int, name sysname,internal_value int,character_value varchar(30))
insert into tmp([index],name,internal_value,character_value) exec xp_msver PhysicalMemory

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'ipadd') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)                      
drop table ipadd
create table ipadd (server varchar(100)default cast( serverproperty ('Machinename') as varchar),IP varchar (100))
insert into ipadd (IP)exec xp_cmdshell 'ipconfig'
delete from ipadd where ip not like '%IP Address.%' or IP is null




-- Step 11 : Getting the Server details 


SELECT  top 1              
@domain as 'Domain',                      
serverproperty('Machinename') as 'MachineName',                      
@CPU as 'CPUCount',
cast (t.internal_value as bigint) as PhysicalMemoryMB,
cast(substring ( I.IP , 44,41) as nvarchar(20))as IP_Address,
serverproperty('Instancename') as 'InstanceName',                      
@image_path as 'BinariesPath',                      
@log_directory as 'ErrorLogsLocation',                      
@start_username as 'StartupUser',                      
@Startuptype as 'StartupType',                      
serverproperty('Productlevel') as 'ServicePack',                      
serverproperty('edition') as 'Edition',                      
serverproperty('productversion') as 'Version',                      
serverproperty('collation') as 'Collation',                      
serverproperty('Isclustered') as 'ISClustered',                      
@Out as 'ClustreNodes',
serverproperty('IsFullTextInstalled') as 'ISFullText'                       
From tmp t inner join IPAdd I
on t.server = I.server


--Step 12 : Getting the instance details 


SELECT                       
serverproperty ('Machinename') as 'Machine',                      
serverproperty ('Instancename') as 'InstanceName',                      
(SELECT 'file_type' =                      
CASE                      
WHEN s.groupid <> 0 THEN 'data'                      
WHEN s.groupid = 0 THEN 'log'                      
END) AS 'fileType'                      
, d.dbid as 'DBID'                      
, d.name AS 'DBName'                      
, s.name AS 'LogicalFileName'                      
, s.filename AS 'PhysicalFileName'                      
, (s.size * 8 / 1024) AS 'FileSizeMB' -- file size in MB                      
,d.cmptlevel as 'CompatibilityLevel'                      
, DATABASEPROPERTYEX (d.name,'Recovery') as 'RecoveryModel'                      
, DATABASEPROPERTYEX (d.name,'Status') as 'DatabaseStatus' ,                     
(SELECT 'is_replication' =                      
CASE                      
WHEN d.category = 1 THEN 'Published'                      
WHEN d.category = 2 THEN 'subscribed'                      
WHEN d.category = 4 THEN 'Merge published'
WHEN d.category = 8 THEN 'merge subscribed'
Else 'NO replication'
 END) AS 'Is_replication',
 @Mirroring as 'MirroringState'
FROM                      
sysdatabases d INNER JOIN sysaltfiles s                      
ON                      
d.dbid=s.dbid                      
ORDER BY                      
d.name                      


--Step 13 : Getting backup details 


Select distinct                             
b.machine_name as 'ServerName',                        
b.server_name as 'InstanceName',                        
b.database_name as 'DatabaseName',                            
d.dbid 'DBID',                            
CASE b.[type]                                  
WHEN 'D' THEN 'Full'                                  
WHEN 'I' THEN 'Differential'                                  
WHEN 'L' THEN 'Transaction Log'                                  
END as 'BackupType'                                 
from sysdatabases d inner join msdb.dbo.backupset b                            
On b.database_name =d.name   


--Step 14: Dropping the table we created for IP and Physical memory


Drop Table TMP
Drop Table IPADD
drop table Nodes
end
go


--Step 15 : Setting Nulls and Quoted identifier back to Off 

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


print '*********************************'
print '     '
print '     '
print '     '
print '     '


print '----------------------------'
print ' 1.sqlserver all information  '
print '----------------------------'
print '                             '
print '*********************************'
use master
go
print 'ths information about sqlserver '
print '                                '
print @@version
go


print '                                                   '
print '                                                   '
select cast(serverproperty('productversion') as varchar(30)) as 产品版本号,
cast(serverproperty('productlevel') as varchar(30)) as sp_level,
cast(serverproperty('edition') as varchar(30)) as 版本
go
print '                                                   '
print '                                                   '


print 'SQLSERVER max user connect         '
print '                                   '
print @@max_connections
go
print '*********************************'


print '                             '
print '                             '
print '                             '
print '----------------------------'
print '2.查看服务器有哪些数据库'
print '----------------------------'
print '*********************************'
print '                           '
SELECT DatabaseName,DataSize,LogSize,DataSize+LogSize AS TotalSize, Collation, RecoveryType,AutoClose,AutoShrink
FROM 
(SELECT DBID,
CASE Sum(size*8/1024) 
WHEN 0 THEN 1 
ELSE Sum(size*8/1024) 
END AS DataSize
FROM master..sysaltfiles
WHERE GroupID <> 0
GROUP BY DBID) q1
INNER JOIN
(SELECT DBID,
CASE Sum(size*8/1024) 
WHEN 0 THEN 1 
ELSE Sum(size*8/1024)
END AS LogSize
FROM master..sysaltfiles
WHERE GroupID = 0
GROUP BY DBID) q2 
ON q1.DBID = q2.DBID
INNER JOIN
(SELECT DBID, [name] AS DatabaseName,
CONVERT(varchar(100),DATABASEPROPERTYEX([Name], 'Collation')) AS Collation,
CONVERT(varchar(100),DATABASEPROPERTYEX([Name], 'Recovery')) AS RecoveryType,
CASE CONVERT(varchar(10),DATABASEPROPERTYEX([Name], 'IsAutoClose'))
WHEN 0 THEN '-'
WHEN 1 THEN 'Yes'
END  AS AutoClose,
  CASE CONVERT(varchar(10),DATABASEPROPERTYEX([Name], 'IsAutoShrink'))
WHEN 0 THEN '-'
WHEN 1 THEN 'Yes'
END AS AutoShrink
FROM master.dbo.sysdatabases) q3
ON q1.DBID = q3.dbid
ORDER BY DatabaseName 
print '*********************************'




print '                             '
print '                             '
print '                             '
print '----------------------------'
print '3.查看每个数据库具体结构信息'
print'----------------------------'
print '*********************************'
print '                         '
use master
go
declare @databasename varchar(50)
declare cur01 cursor for
select name from sys.databases
open cur01
fetch next from cur01 into @databasename
while @@fetch_status=0
begin
begin
select 'databasename:  '+ @databasename
print '                     '
exec sp_helpdb @databasename
end
fetch next from cur01 into @databasename;
end;
close cur01
deallocate cur01
go
print '*********************************'






print '                             '
print '                             '
print '                             '
print '----------------------------'
print '4.1所有数据库的index          '
print '----------------------------'
print '*********************************'
use master
go
BEGIN
CREATE TABLE #INDEXFRAGINFO
(
DatabaseName nvarchar(128),
DatabaseID smallint,
full_obj_name nvarchar(384),
index_id INT, 
[name] nvarchar(128), 
index_type_desc nvarchar(60), 
index_depth tinyint,
index_level tinyint,
[AVG Fragmentation] float, 
fragment_count bigint,
[Rank] bigint 
)


DECLARE @command VARCHAR(1000) 
SELECT @command = 'Use [' + '?' + '] select ' + '''' + '?' + '''' + ' AS DatabaseName,
DB_ID() AS DatabaseID,
QUOTENAME(DB_NAME(i.database_id), '+ '''' + '"' + '''' +')+ N'+ '''' + '.' + '''' +'+ QUOTENAME(OBJECT_SCHEMA_NAME(i.object_id, i.database_id), '+ '''' + '"' + '''' +')+ N'+ '''' + '.' + '''' +'+ QUOTENAME(OBJECT_NAME(i.object_id, i.database_id), '+ '''' + '"' + '''' +') as full_obj_name, 
i.index_id,
o.name, 
i.index_type_desc, 
i.index_depth,
i.index_level,
i.avg_fragmentation_in_percent as [AVG Fragmentation], 
i.fragment_count, 
i.rnk as Rank
from (
select *, DENSE_RANK() OVER(PARTITION by database_id ORDER BY avg_fragmentation_in_percent DESC) as rnk
from sys.dm_db_index_physical_stats(DB_ID(), default, default, default,'+ '''' + 'limited' + '''' +')
where avg_fragmentation_in_percent >0 AND 
INDEX_ID > 0 AND 
Page_Count > 500 
) as i
join sys.indexes o on o.object_id = i.object_id and o.index_id = i.index_id
where i.rnk <= 25
order by i.database_id, i.rnk;'


INSERT #INDEXFRAGINFO EXEC sp_MSForEachDB @command 


SELECT substring(databasename,0,30) as databasename ,ltrim(databaseID) as databaseID,substring(full_obj_name,0,50) as full_obj_name ,
ltrim(index_id) as index_id, [name], 
index_type_desc, ltrim(index_depth) as index_depth, ltrim(index_level) as index_level, ltrim([AVG Fragmentation]) as [AVG Fragmentation] ,
 ltrim(fragment_count) as fragment_count, ltrim([Rank]) as [Rank]
FROM #INDEXFRAGINFO
Where DatabaseID > 4
order by [RANK];


DROP TABLE #INDEXFRAGINFO


END
GO


print '*********************************'








print '                             '
print '                             '
print '                             '
print '----------------------------'
print '4.2找出很少使用的index         '
print '----------------------------'
print '*********************************'




declare @dbid int
select @dbid = db_id()
select objectname=object_name(s.object_id), s.object_id
, indexname=i.name, i.index_id
, user_seeks AS 搜索次数, user_scans AS 扫描次数, 
user_lookups AS 查找次数, user_updates 更新次数
from sys.dm_db_index_usage_stats s,
sys.indexes i
where database_id = @dbid 
and objectproperty(s.object_id,'IsUserTable') = 1
and i.object_id = s.object_id
and i.index_id = s.index_id
order by (user_seeks + user_scans + user_lookups + user_updates) asc
go


print '                             '
print '                             '
print '                             '
print '----------------------------'
print '4.3所有数据库未使用的索引  '
print '----------------------------'
print '*********************************'


SELECT TOP 1
        DatabaseName = DB_NAME()
        ,TableName = OBJECT_NAME(s.[object_id])
        ,IndexName = i.name
        ,user_updates    
        ,system_updates    
        -- Useful fields below:
        --, *
INTO #TempUnusedIndexes
FROM   sys.dm_db_index_usage_stats s 
INNER JOIN sys.indexes i ON  s.[object_id] = i.[object_id] 
    AND s.index_id = i.index_id 
WHERE  s.database_id = DB_ID()
    AND OBJECTPROPERTY(s.[object_id], 'IsMsShipped') = 0
    AND    user_seeks = 0
    AND user_scans = 0 
    AND user_lookups = 0
    AND s.[object_id] = -999  -- Dummy value to get table structure.
;


-- Loop around all the databases on the server.
EXEC sp_MSForEachDB    'USE [?]; 
-- Table already exists.
INSERT INTO #TempUnusedIndexes 
SELECT TOP 10    
        DatabaseName = DB_NAME()
        ,TableName = OBJECT_NAME(s.[object_id])
        ,IndexName = i.name
        ,user_updates    
        ,system_updates    
FROM   sys.dm_db_index_usage_stats s 
INNER JOIN sys.indexes i ON  s.[object_id] = i.[object_id] 
    AND s.index_id = i.index_id 
WHERE  s.database_id = DB_ID()
    AND OBJECTPROPERTY(s.[object_id], ''IsMsShipped'') = 0
    AND    user_seeks = 0
    AND user_scans = 0 
    AND user_lookups = 0
    AND i.name IS NOT NULL    -- Ignore HEAP indexes.
ORDER BY user_updates DESC
;
'


-- Select records.
SELECT TOP 10 * FROM #TempUnusedIndexes ORDER BY [user_updates] DESC
-- Tidy up.
DROP TABLE #TempUnusedIndexes


print '                             '
print '                             '
print '                             '
print '----------------------------'
print '4.4所有数据库高开销的缺失索引  '
print '----------------------------'
print '*********************************'


SELECT  TOP 10 
        [Total Cost]  = ROUND(avg_total_user_cost * avg_user_impact * (user_seeks + user_scans),0) 
        , avg_user_impact
        , TableName = statement
        , [EqualityUsage] = equality_columns 
        , [InequalityUsage] = inequality_columns
        , [Include Cloumns] = included_columns
FROM        sys.dm_db_missing_index_groups g 
INNER JOIN    sys.dm_db_missing_index_group_stats s 
       ON s.group_handle = g.index_group_handle 
INNER JOIN    sys.dm_db_missing_index_details d 
       ON d.index_handle = g.index_handle
ORDER BY [Total Cost] DESC;


print '                             '
print '                             '
print '                             '
print '----------------------------'
print '5.查询数据库IO                 '
print '----------------------------'
print '*********************************'
go
WITH IOFORDATABASE AS
(
SELECT
 DB_NAME(VFS.database_id) AS DatabaseName
,CASE WHEN smf.type = 1 THEN 'LOG_FILE' ELSE 'DATA_FILE' END AS DatabaseFile_Type
,SUM(VFS.num_of_bytes_written) AS IO_Write
,SUM(VFS.num_of_bytes_read) AS IO_Read
,SUM(VFS.num_of_bytes_read + VFS.num_of_bytes_written) AS Total_IO
,SUM(VFS.io_stall) AS IO_STALL
FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS VFS
JOIN sys.master_files AS smf
  ON VFS.database_id = smf.database_id
 AND VFS.file_id = smf.file_id
GROUP BY 
 DB_NAME(VFS.database_id)
,smf.type
)
SELECT 
 ltrim(ROW_NUMBER() OVER(ORDER BY io_stall DESC)) AS RowNumber
,substring(DatabaseName,1,30) as DatabaseName


,DatabaseFile_Type
,ltrim(CAST(1.0 * IO_Read/ (1024 * 1024) AS DECIMAL(12, 2))) AS IO_Read_MB
,ltrim(CAST(1.0 * IO_Write/ (1024 * 1024) AS DECIMAL(12, 2))) AS IO_Write_MB
,ltrim(CAST(1. * Total_IO / (1024 * 1024) AS DECIMAL(12, 2))) AS IO_TOTAL_MB
,ltrim(CAST(IO_STALL / 1000. AS DECIMAL(12, 2))) AS IO_STALL_Seconds
,ltrim(CAST(100. * IO_STALL / SUM(IO_STALL) OVER() AS DECIMAL(10, 2))) AS IO_STALL_Pct
FROM IOFORDATABASE
ORDER BY IO_STALL_Seconds DESC;
go
print '*********************************'




print '                             '
print '                             '
print '                             '
print '----------------------------'
print '6.查看数据库是否有死锁         '
print '----------------------------'
print '*********************************'
use master
go
select ltrim(request_session_id) "会话ID",
substring(resource_type,1,30) "被锁定的资源",
resource_database_id "数据库",
object_name(resource_associated_entity_id) "对象",
request_mode "资源模式",
request_status  "锁状态"
from sys.dm_tran_locks
go
print '*********************************'




print '                             '
print '                             '
print '                             '
print '----------------------------'
print '7.查看性能统计信息             '
print'----------------------------'
print '*********************************'
use master
go
dbcc freeproccache
go
select t.text as "执行的文本", st.total_logical_reads  as "逻辑读取总次数",
st.total_physical_reads  as "物理读取总次数",
st.total_elapsed_time/1000000 as "占用的总时间",
st.total_logical_writes  as "逻辑写入总次数"
from sys.dm_exec_query_stats st
cross apply sys.dm_exec_sql_text(st.sql_handle) t
go
print '*********************************'






print '                             '
print '                             '
print '                             '
print '----------------------------'
print '8.临时数据库使用情况              '
print '----------------------------'
print '*********************************'
use master
go
select ltrim(sum(user_object_reserved_page_count)*8) as user_objects_kb,
   ltrim(sum(internal_object_reserved_page_count)*8) as internal_objects_kb,
   ltrim(sum(version_store_reserved_page_count)*8) as version_store_kb,
   ltrim(sum(unallocated_extent_page_count)*8) as freespace_kb
from sys.dm_db_file_space_usage
where database_id = 2
go
print '*********************************'




print '                             '
print '                             '
print '                             '
print '----------------------------'
print '9.查CPU瓶颈                    '
print '----------------------------'
print '*********************************'
use master
go
Select ltrim(scheduler_id) as scheduler_id,
ltrim(current_tasks_count) as current_tasks_count ,
ltrim(runnable_tasks_count) as current_tasks_count
from sys.dm_os_schedulers where scheduler_id<255 
go
print '*********************************'




print '                             '
print '                             '
print '                             '
print '------------------------------------------'
print '10.当前被缓存的消耗CPU资源最多的批处理或者过程'
print '------------------------------------------'
print '*********************************'
use master
go
Select top 50 ltrim(sum(total_worker_time)) as total_cpu_time,
ltrim(sum(execution_count)) as total_execution_count, 
ltrim(count(*)) as number_of_statements,plan_handle 
from sys.dm_exec_query_stats qs group by 
plan_handle order by sum(total_worker_time) desc 
go
print '*********************************'




print '                             '
print '                             '
print '                             '
print '--------------------------------------------'
print '11.查询前100个缓存使用率高、最消耗缓存的sql语句'
print '--------------------------------------------'
print '*********************************'
use master
go
select top 100 ltrim(usecounts) as usecounts,
objtype,
ltrim(p.size_in_bytes) as  size_in_bytes ,
sql.text
from sys.dm_exec_cached_plans  p
outer apply
sys.dm_exec_sql_text(p.plan_handle) sql
order by usecounts desc
go
print '*********************************'




print '                             '
print '                             '
print '                             '
print '---------------------------------------------------------------'
print '12.解数据库中的缓存情况，包括被使用的次数、缓存类型、占用的内存大小'
print '---------------------------------------------------------------'
print '*********************************'
use master
go
SELECT usecounts=ltrim(usecounts), substring(cacheobjtype,1,30) as cacheobjtype, objtype,ltrim(size_in_bytes) as size_in_bytes, plan_handle
FROM sys.dm_exec_cached_plans
go
print '*********************************'






print '                             '
print '                             '
print '                             '
print '----------------------------'
print '13.计划缓存总数'
print '----------------------------'
print '*********************************'
use master
go
Select ltrim(Count(*)) CNT,
cast(sum(size_in_bytes)/1024/1024 as varchar(100))+' MB' TotalSize
From sys.dm_exec_cached_plans
go
print '*********************************'




print '                             '
print '                             '
print '                             '
print '--------------------------------------'
print '14.检查SQL Server的执行缓存和数据缓存占用'
print '--------------------------------------'
print '*********************************'
use master
go
dbcc memorystatus 
go
print '*********************************'






print '                             '
print '                             '
print '                             '
print '-------------------------------------'
print '15.所有数据库备份情况'
print '-------------------------------------'
print '*********************************'
-- sql server 2000/2005 version


use master
go
set nocount on
go
declare @counter smallint
declare @dbname varchar(100)
declare @db_bkpdate varchar(100)
declare @status varchar(20)
declare @svr_name varchar(100)
declare @media_set_id varchar(20)
declare @filepath varchar(1000)
declare @filestatus int
declare @fileavailable varchar(20)
declare @backupsize float


select @counter=max(dbid) from master..sysdatabases
create table #backup_details 
(
servername varchar(100),
databasename varchar(100),
bkpdate varchar(20) null,
backupsize_in_mb varchar(20),
status varchar(20),
filepath varchar(1000),
fileavailable varchar(200)
)
select @svr_name = cast(serverproperty('servername')as sysname)
while @counter > 0
begin
/* need to re-initialize all variables*/
select @dbname = null , @db_bkpdate = null ,
@media_set_id = null , @backupsize = null ,
@filepath = null , @filestatus = null , 
@fileavailable = null , @status = null , @backupsize = null


select @dbname = name from master..sysdatabases where dbid = @counter
select @db_bkpdate = max(backup_start_date) from msdb..backupset where database_name = @dbname and type='d'
select @media_set_id = media_set_id from msdb..backupset where backup_start_date = ( select max(backup_start_date) from msdb..backupset where database_name = @dbname and type='d')
select @backupsize = backup_size from msdb..backupset where backup_start_date = ( select max(backup_start_date) from msdb..backupset where database_name = @dbname and type='d')
select @filepath = physical_device_name from msdb..backupmediafamily where media_set_id = @media_set_id
exec master..xp_fileexist @filepath , @filestatus out
if @filestatus = 1
set @fileavailable = 'available'
else
set @fileavailable = 'not available'
if (datediff(day,@db_bkpdate,getdate()) > 7)
set @status = 'warning'
else
set @status = 'healthy'
set @backupsize = (@backupsize/1024)/1024
insert into #backup_details select @svr_name,@dbname,@db_bkpdate,@backupsize,@status,@filepath,@fileavailable
update #backup_details
set status = 'warning' where bkpdate is null
set @counter = @counter - 1
end
select substring(servername,0,20) AS [服务器名],
substring(databasename,0,20) AS [数据库名], 
rtrim(ltrim(bkpdate)) AS  [备份日期],
rtrim(ltrim(backupsize_in_mb)) AS [备份大小],
rtrim(ltrim([status])) AS [备份状态],
substring(rtrim(ltrim(filepath)),0,40) AS  [备份文件路径],
rtrim(fileavailable) AS  [备份文件是否可用]
 from #backup_details where databasename not in ('tempdb','northwind','pubs')
drop table #backup_details
set nocount off
go


print '*********************************'






print '                             '
print '                             '
print '                             '
print '-------------------------------------'
print '16.监控CPU瓶颈'
print '-------------------------------------'
print '*********************************'
use master
go


print '-------------------------------------'
print '16.1当前缓存的哪些批处理或过程占用了大部分 CPU 资源'
print '-------------------------------------'
SELECT TOP 50 
      ltrim(SUM(qs.total_worker_time)) AS total_cpu_time, 
      ltrim(SUM(qs.execution_count)) AS total_execution_count,
      ltrim(COUNT(*)) AS  number_of_statements, 
      qs.sql_handle 
FROM sys.dm_exec_query_stats AS qs
GROUP BY qs.sql_handle
ORDER BY SUM(qs.total_worker_time) DESC
go




print '                             '
print '                             '
print '-------------------------------------------------------'
print '16.2查询显示缓存计划所占用的 CPU 总使用率（带 SQL 文本）'
print '-------------------------------------------------------'
SELECT 
      total_cpu_time, 
      total_execution_count,
      number_of_statements,
      s2.text
      --(SELECT SUBSTRING(s2.text, statement_start_offset / 2, ((CASE WHEN statement_end_offset = -1 THEN (LEN(CONVERT(NVARCHAR(MAX), s2.text)) * 2) ELSE statement_end_offset END) - statement_start_offset) / 2) ) AS query_text
FROM 
      (SELECT TOP 50 
            SUM(qs.total_worker_time) AS total_cpu_time, 
            SUM(qs.execution_count) AS total_execution_count,
            COUNT(*) AS  number_of_statements, 
            qs.sql_handle --,
            --MIN(statement_start_offset) AS statement_start_offset, 
            --MAX(statement_end_offset) AS statement_end_offset
      FROM 
            sys.dm_exec_query_stats AS qs
      GROUP BY qs.sql_handle
      ORDER BY SUM(qs.total_worker_time) DESC) AS stats
      CROSS APPLY sys.dm_exec_sql_text(stats.sql_handle) AS s2
go


print '                             '
print '                             '
print '-------------------------------------------------------'
print '16.3显示 CPU 平均占用率最高的前 50 个 SQL 语句'
print '-------------------------------------------------------'


SELECT TOP 50
total_worker_time/execution_count AS [Avg CPU Time],
(SELECT SUBSTRING(text,statement_start_offset/2,(CASE WHEN statement_end_offset = -1 then LEN(CONVERT(nvarchar(max), text)) * 2 ELSE statement_end_offset end -statement_start_offset)/2) FROM sys.dm_exec_sql_text(sql_handle)) AS query_text, *
FROM sys.dm_exec_query_stats 
ORDER BY [Avg CPU Time] DESC
go


print '                             '
print '                             '
print '-------------------------------------------------------'
print '16.4找出过多编译/重新编译的 DMV 查询'
print '-------------------------------------------------------'
select * from sys.dm_exec_query_optimizer_info
where 
      counter = 'optimizations'
      or counter = 'elapsed time'
go




print '                             '
print '                             '
print '-------------------------------------------------------'
print '16.5显示已重新编译的前 25 个存储过程'
print '-------------------------------------------------------'
select top 25
      sql_text.text,
      sql_handle,
      plan_generation_num,
      execution_count,
      dbid,
      objectid 
from sys.dm_exec_query_stats a
      cross apply sys.dm_exec_sql_text(sql_handle) as sql_text
where plan_generation_num > 1
order by plan_generation_num desc
go




print '                             '
print '                             '
print '-------------------------------------------------------'
print '16.6哪个查询占用了最多的 CPU 累计使用率'
print '-------------------------------------------------------'


SELECT 
    ltrim(highest_cpu_queries.plan_handle) as plan_handle, 
    ltrim(highest_cpu_queries.total_worker_time) as total_worker_time,
    q.dbid,
    ltrim(q.objectid),
    q.number,
    q.encrypted,
    q.[text]
from 
    (select top 50 
        qs.plan_handle, 
        qs.total_worker_time
    from 
        sys.dm_exec_query_stats qs
    order by qs.total_worker_time desc) as highest_cpu_queries
    cross apply sys.dm_exec_sql_text(plan_handle) as q
order by highest_cpu_queries.total_worker_time desc
go




print '                             '
print '                             '
print '-------------------------------------------------------'
print '16.7可能占用大量 CPU 使用率的运算符
print '-------------------------------------------------------'


select *
from 
      sys.dm_exec_cached_plans
      cross apply sys.dm_exec_query_plan(plan_handle)
where 
      cast(query_plan as nvarchar(max)) like '%Sort%'
      or cast(query_plan as nvarchar(max)) like '%Hash Match%'
go




print '                             '
print '                             '
print '-------------------------------------------------------'
print '17.内存瓶颈'
print '-------------------------------------------------------'
print '                             '
print '                             '
print '-------------------------------------------------------'
print '17.1确保已启用 SQL Server 中的高级选项'
print '-------------------------------------------------------'
use master
go
sp_configure 'show advanced options'
go
sp_configure 'show advanced options', 1
go
reconfigure
go




print '                             '
print '                             '
print '-------------------------------------------------------'
print '17.2运行以下查询以检查内存相关配置选项'
print '-------------------------------------------------------'


sp_configure 'awe_enabled'
go
sp_configure 'min server memory'
go
sp_configure 'max server memory'
go
sp_configure 'min memory per query'
go
sp_configure 'query wait'
go


print '                             '
print '                             '
print '-------------------------------------------------------'
print '17.3查看 CPU、计划程序内存和缓冲池信息'
print '-------------------------------------------------------'


select 
ltrim(cpu_count) as cpu_count,
ltrim(hyperthread_ratio) as hyperthread_ratio,
ltrim(scheduler_count) as scheduler_count,
ltrim(physical_memory_in_bytes / 1024 / 1024) as physical_memory_mb,
ltrim(virtual_memory_in_bytes / 1024 / 1024) as virtual_memory_mb,
ltrim(bpool_committed * 8 / 1024) as bpool_committed_mb,
ltrim(bpool_commit_target * 8 / 1024) as bpool_target_mb,
ltrim(bpool_visible * 8 / 1024) as bpool_visible_mb
from sys.dm_os_sys_info
go


print '                             '
print '                             '
print '-------------------------------------------------------'
print '17.4I/O 瓶颈'
print '-------------------------------------------------------'
select wait_type, ltrim(waiting_tasks_count) as waiting_tasks_count , ltrim(wait_time_ms) as wait_time_ms , 
ltrim(signal_wait_time_ms) as signal_wait_time_ms, ltrim(wait_time_ms / waiting_tasks_count) as avgtime
from sys.dm_os_wait_stats  
where wait_type like 'PAGEIOLATCH%'  and waiting_tasks_count > 0
order by wait_type
go


print '                             '
print '                             '
print '-------------------------------------------------------'
print '17.5查找当前挂起的 I/O 请求'
print '-------------------------------------------------------'


print '正常情况下不返回任何值'


select 
    database_id, 
    file_id, 
    io_stall,
    io_pending_ms_ticks,
    scheduler_address 
from  sys.dm_io_virtual_file_stats(NULL, NULL)t1,
        sys.dm_io_pending_io_requests as t2
where t1.file_handle = t2.io_handle
go




print '                             '
print '                             '
print '-------------------------------------------------------'
print '17.6查看IO相关查询读取次数'
print '-------------------------------------------------------'


select top 5 (total_logical_reads/execution_count) as avg_logical_reads,
                   (total_logical_writes/execution_count) as avg_logical_writes,
           (total_physical_reads/execution_count) as avg_physical_reads,
           Execution_count, statement_start_offset, p.query_plan, q.text
from sys.dm_exec_query_stats
      cross apply sys.dm_exec_query_plan(plan_handle) p
      cross apply sys.dm_exec_sql_text(plan_handle) as q
order by (total_logical_reads + total_logical_writes)/execution_count Desc
go




print '                             '
print '                             '
print '-------------------------------------------------------'
print '17.7查找哪些批处理/请求生成的 I/O 最多'
print '-------------------------------------------------------'


select top 5 
    ltrim(total_logical_reads/execution_count) as avg_logical_reads,
    ltrim(total_logical_writes/execution_count) as avg_logical_writes,
    ltrim(total_physical_reads/execution_count) as avg_phys_reads,
     ltrim(Execution_count) as Execution_count, 
    ltrim(statement_start_offset) as stmt_start_offset, 
    sql_handle, 
    plan_handle
from sys.dm_exec_query_stats  
order by  (total_logical_reads + total_logical_writes) Desc
go



print '                             '
print '                             '
print '-------------------------------------------------------'
print '18.阻塞'
print '-------------------------------------------------------'


print '                             '
print '                             '
print '-------------------------------------------------------'
print '18.1 确定阻塞的会话'
print '-------------------------------------------------------'
use master
go
select blocking_session_id, wait_duration_ms, session_id from 
sys.dm_os_waiting_tasks
where blocking_session_id is not null
go


print '                             '
print '                             '
print '-------------------------------------------------------'
print '18.2 SQL 等待分析和前 10 个等待的资源'
print '-------------------------------------------------------'
select top 10 ltrim(wait_type) as wait_type, ltrim(waiting_tasks_count) as waiting_tasks_count,
 ltrim(wait_time_ms) as  wait_time_ms,   
 ltrim(max_wait_time_ms) as  max_wait_time_ms,
 ltrim(signal_wait_time_ms) as signal_wait_time_ms
from sys.dm_os_wait_stats
--where wait_type not in ('CLR_SEMAPHORE','LAZYWRITER_SLEEP','RESOURCE_QUEUE','SLEEP_TASK','SLEEP_SYSTEMTASK','WAITFOR')
order by wait_time_ms desc
go



print '                             '
print '                             '
print '-------------------------------------------------------'
print '19. 查看各个数据库性能负载'
print '-------------------------------------------------------'


SELECT
substring (a.name,0,12) as [数据库名],
[连接数] = (SELECT COUNT(*)
FROM master..sysprocesses b
WHERE
a.dbid = b.dbid),


[阻塞进程] = (SELECT COUNT(*)
FROM master..sysprocesses b
WHERE
a.dbid = b.dbid AND
blocked <> 0),


[总内存] = ISNULL((SELECT SUM(memusage)
FROM
master..sysprocesses b
WHERE
a.dbid = b.dbid),0),


[总IO] = ISNULL((SELECT SUM(physical_io)
FROM
master..sysprocesses b
WHERE
a.dbid = b.dbid),0),


[总CPU] = ISNULL((SELECT SUM(cpu)
FROM
master..sysprocesses b
WHERE
a.dbid = b.dbid),0),


[总等待时间] = ISNULL((SELECT SUM(waittime)
FROM
master..sysprocesses b
WHERE
a.dbid = b.dbid),0),


[SELECTs] = (SELECT COUNT(*) 
FROM master..sysprocesses b
WHERE 
a.dbid = b.dbid AND
b.cmd LIKE '%SELECT%'),


[DELETEs] = (SELECT COUNT(*) 
FROM master..sysprocesses b
WHERE 
a.dbid = b.dbid AND
b.cmd LIKE '%DELETE%'),


[DBCC Commands] = ISNULL((SELECT COUNT(*)
FROM
master..sysprocesses b
WHERE
a.dbid = b.dbid and
b.cmd like '%DBCC%'),0),


[BCP Running] = ISNULL((SELECT COUNT(*)
FROM
master..sysprocesses b
WHERE
a.dbid = b.dbid and
b.cmd like '%BCP%'),0),


[Backups Running] = ISNULL((SELECT COUNT(*)
FROM
master..sysprocesses b
WHERE
a.dbid = b.dbid and
b.cmd LIKE '%BACKUP%'),0)


FROM master.dbo.sysdatabases a WITH (nolock)
WHERE 
DatabasePropertyEx(a.name,'Status') = 'ONLINE'
ORDER BY [数据库名]
go



print '                             '
print '                             '
print '-------------------------------------------------------'
print '20. 查看所有数据库大小、恢复模式等信息'
print '-------------------------------------------------------'
SELECT substring (DatabaseName,0,12) as DatabaseName,DataSize,LogSize,DataSize+LogSize AS TotalSize, Collation, RecoveryType,AutoClose,AutoShrink
FROM 
(SELECT DBID,
CASE Sum(size*8/1024) 
WHEN 0 THEN 1 
ELSE Sum(size*8/1024) 
END AS DataSize
FROM master..sysaltfiles
WHERE GroupID <> 0
GROUP BY DBID) q1
INNER JOIN
(SELECT DBID,
CASE Sum(size*8/1024) 
WHEN 0 THEN 1 
ELSE Sum(size*8/1024)
END AS LogSize
FROM master..sysaltfiles
WHERE GroupID = 0
GROUP BY DBID) q2 
ON q1.DBID = q2.DBID
INNER JOIN
(SELECT DBID, [name] AS DatabaseName,
CONVERT(varchar(100),DATABASEPROPERTYEX([Name], 'Collation')) AS Collation,
CONVERT(varchar(100),DATABASEPROPERTYEX([Name], 'Recovery')) AS RecoveryType,
CASE CONVERT(varchar(10),DATABASEPROPERTYEX([Name], 'IsAutoClose'))
WHEN 0 THEN '-'
WHEN 1 THEN 'Yes'
END  AS AutoClose,
  CASE CONVERT(varchar(10),DATABASEPROPERTYEX([Name], 'IsAutoShrink'))
WHEN 0 THEN '-'
WHEN 1 THEN 'Yes'
END AS AutoShrink
FROM master.dbo.sysdatabases) q3
ON q1.DBID = q3.dbid
ORDER BY DatabaseName 


print '                             '
print '                             '
print '-------------------------------------------------------'
print '21. 查看数据库群集信息'
print '-------------------------------------------------------'


PRINT ' **** Cluster Information ****'
PRINT ' '
PRINT ' The following is information on the cluster you are connected'
PRINT ' '
PRINT '... Name of all nodes used and are part of this failover cluster'
SELECT * FROM sys.dm_os_cluster_nodes 
PRINT ' '
PRINT '... Node which is the active '
SELECT SERVERPROPERTY('ComputerNamePhysicalNetBIOS') 
PRINT ' '
PRINT '... Drive letters that are part of the resourse group which contain the data and log files'
SELECT * FROM sys.dm_io_cluster_shared_drives
go




print '                             '
print '                             '
print '-------------------------------------------------------'
print '22. 当前数据库服务器登录用户、会话连接数、认证类型'
print '-------------------------------------------------------'


SELECT '认证方式'=(
CASE 
WHEN nt_user_name IS not null THEN 'windows认证' 
ELSE 'SQL认证' 
END),
login_name AS '登录名', ISNULL(nt_user_name,'-') AS 'Windows登录名',
COUNT(session_id) AS '会话数'
FROM sys.dm_exec_sessions
GROUP BY login_name,nt_user_name
go




print '                             '
print '                             '
print '-------------------------------------------------------'
print '23. 查看执行效率低的语句'
print '-------------------------------------------------------'



SELECT creation_time  N'语句编译时间'
        ,last_execution_time  N'上次执行时间'
        ,total_physical_reads N'物理读取总次数'
        ,total_logical_reads/execution_count N'每次逻辑读次数'
        ,total_logical_reads  N'逻辑读取总次数'
        ,total_logical_writes N'逻辑写入总次数'
        ,execution_count  N'执行次数'
        ,total_worker_time/1000 N'所用的CPU总时间ms'
        ,total_elapsed_time/1000  N'总花费时间ms'
        ,(total_elapsed_time / execution_count)/1000  N'平均时间ms'
        ,SUBSTRING(st.text, (qs.statement_start_offset/2) + 1,
         ((CASE statement_end_offset
          WHEN -1 THEN DATALENGTH(st.text)
          ELSE qs.statement_end_offset END
            - qs.statement_start_offset)/2) + 1) N'执行语句'
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
where SUBSTRING(st.text, (qs.statement_start_offset/2) + 1,
         ((CASE statement_end_offset
          WHEN -1 THEN DATALENGTH(st.text)
          ELSE qs.statement_end_offset END
            - qs.statement_start_offset)/2) + 1) not like '%fetch%'
ORDER BY  total_elapsed_time / execution_count DESC;



print '                             '
print '                             '
print '-------------------------------------------------------'
print '24. 所有数据库高开销的缺失索引'
print '-------------------------------------------------------'


SELECT  TOP 100 
        [Total Cost]  = ROUND(avg_total_user_cost * avg_user_impact * (user_seeks + user_scans),0) 
        , avg_user_impact
        , TableName = statement
        , [EqualityUsage] = equality_columns 
        , [InequalityUsage] = inequality_columns
        , [Include Cloumns] = included_columns
FROM        sys.dm_db_missing_index_groups g 
INNER JOIN    sys.dm_db_missing_index_group_stats s 
       ON s.group_handle = g.index_group_handle 
INNER JOIN    sys.dm_db_missing_index_details d 
       ON d.index_handle = g.index_handle
ORDER BY [Total Cost] DESC;


print '                             '
print '                             '
print '-------------------------------------------------------'
print '25. 查看buffer cache命中率'
print '-------------------------------------------------------'


 SELECT  
(CAST(SUM(CASE LTRIM(RTRIM(counter_name))    
WHEN 'Buffer cache hit ratio'    
THEN CAST(cntr_value AS INTEGER) ELSE NULL END) AS FLOAT) /   
CAST(SUM(CASE LTRIM(RTRIM(counter_name))    
WHEN 'Buffer cache hit ratio base' THEN CAST(cntr_value AS INTEGER)ELSE NULL END) AS FLOAT)) * 100   
AS BufferCacheHitRatio   
FROM sys.dm_os_performance_counters    
WHERE LTRIM(RTRIM([object_name])) LIKE '%:Buffer Manager' AND    
 [counter_name] LIKE 'Buffer Cache Hit Ratio%'  
go


print '                             '
print '                             '
print '-------------------------------------------------------'
print '26. 查看job执行情况'
print '-------------------------------------------------------'



SELECT 作业名     = sj.name 
      ,开始时间 = sja.start_execution_date 
      ,结束时间   = sja.stop_execution_date 
      ,状态    = CASE  
                   WHEN ISNULL(sjh.run_status,-1) = -1 AND sja.start_execution_date IS NULL AND sja.stop_execution_date IS NULL THEN 'Idle' 
                   WHEN ISNULL(sjh.run_status,-1) = -1 AND sja.start_execution_date IS NOT NULL AND sja.stop_execution_date IS NULL THEN 'Running' 
                   WHEN ISNULL(sjh.run_status,-1) =0  THEN 'Failed' 
                   WHEN ISNULL(sjh.run_status,-1) =1  THEN 'Succeeded' 
                   WHEN ISNULL(sjh.run_status,-1) =2  THEN 'Retry' 
                   WHEN ISNULL(sjh.run_status,-1) =3  THEN 'Canceled' 
                   END 
  FROM MSDB.DBO.sysjobs sj 
  JOIN MSDB.DBO.sysjobactivity sja 
    ON sj.job_id = sja.job_id  
  JOIN (SELECT MaxSessionid = MAX(Session_id) FROM MSDB.DBO.syssessions) ss 
    ON ss.MaxSessionid = sja.session_id 
LEFT JOIN MSDB.DBO.sysjobhistory sjh 
    ON sjh.instance_id = sja.job_history_id




print '                             '
print '                             '
print '-------------------------------------------------------'
print '27. 获得每个数据库空间使用情况'
print '-------------------------------------------------------'
CREATE TABLE #output( 
server_name varchar(128), 
dbname varchar(128), 
physical_name varchar(260), 
dt datetime, 
file_group_name varchar(128), 
size_mb int, 
free_mb int)  
 
exec sp_MSforeachdb @command1= 
'USE [?]; INSERT #output 
SELECT CAST(SERVERPROPERTY(''ServerName'') AS varchar(128)) AS server_name, 
''?'' AS dbname, 
f.filename AS physical_name, 
CAST(FLOOR(CAST(getdate() AS float)) AS datetime) AS dt, 
g.groupname, 
CAST (size*8.0/1024.0 AS int) AS ''size_mb'', 
CAST((size - FILEPROPERTY(f.name,''SpaceUsed''))*8.0/1024.0 AS int) AS ''free_mb'' 
FROM sysfiles f 
JOIN sysfilegroups g 
ON f.groupid = g.groupid' 
 
SELECT * FROM #output 


drop TABLE #output


print '                             '
print '                             '
print '-------------------------------------------------------'
print '28.Buffer Pool缓冲池里面修改过的页总数大小'
print '-------------------------------------------------------'


SELECT count(*) * 8/1024 as cached_pages_mb,
convert(varchar(5),convert(decimal(5,2),(100-1.0*(select count(*) from sys.dm_os_buffer_descriptors b 
where b.database_id=a.database_id and is_modified=0)/count(*)*100.0)))+'%'modified_percentage,
CASE database_id WHEN 32767 THEN 'ResourceDb'
ELSE db_name(database_id)
END AS Database_name
FROM sys.dm_os_buffer_descriptors a
GROUP BY db_name(database_id),database_id
ORDER BY cached_pages_mb DESC;


/*


如果一个数据库的大部分（超过80%）是修改过的，那么这个数据库写操作非常多。
反之如果这个比例接近0，那么该数据库的活动几乎是只读的。读写的比例对磁盘的安排是很重要的。


*/

print '                             '
print '                             '
print '-------------------------------------------------------'
print '29.查看 tempdb 大小和增长参数'
print '-------------------------------------------------------'



SELECT 
    name AS FileName, 
    size*1.0/128 AS FileSizeinMB,
    CASE max_size 
        WHEN 0 THEN 'Autogrowth is off.'
        WHEN -1 THEN 'Autogrowth is on.'
        ELSE 'Log file will grow to a maximum size of 2 TB.'
    END,
    growth AS 'GrowthValue',
    'GrowthIncrement' = 
        CASE
            WHEN growth = 0 THEN 'Size is fixed and will not grow.'
            WHEN growth > 0 AND is_percent_growth = 0 
                THEN 'Growth value is in 8-KB pages.'
            ELSE 'Growth value is a percentage.'
        END
FROM tempdb.sys.database_files;
GO




print '                             '
print '                             '
print '-------------------------------------------------------'
print '30.查看 客户端连接IP'
print '-------------------------------------------------------'


SELECT distinct client_net_address FROM sys.dm_exec_connections 
WHERE session_id >50 and session_id != @@SPID and client_net_address 
not like '%<local machine>%'
go


print '                             '
print '                             '
print '-------------------------------------------------------'
print '31.查看消耗性能的存储过程名、存储过程内容'
print '-------------------------------------------------------'


select distinct procname,text,b.cached_time,
b.last_execution_time,b.total_elapsed_time,
b.avg_elapsed_time,
b.last_elapsed_time,b.execution_count
 from (
select top 1000 sql_text.text as text,
sql_handle,
plan_generation_num,
execution_count,
dbid,
objectid
from sys.dm_exec_query_stats a
cross apply sys.dm_exec_sql_text(sql_handle) as sql_text
where plan_generation_num > 1
order by plan_generation_num desc
)  a,


(
SELECT TOP 1000 d.object_id, d.database_id, OBJECT_NAME(object_id, database_id) 'procname', 
d.cached_time, d.last_execution_time, d.total_elapsed_time, d.total_elapsed_time/d.execution_count AS [avg_elapsed_time],
d.last_elapsed_time, d.execution_count
FROM sys.dm_exec_procedure_stats AS d
ORDER BY [total_worker_time] DESC
) b where a.objectid=b.object_id
order by avg_elapsed_time,execution_count desc
go