1.Oracle RMAN备份
1.1 创建目录
[oracle@OEL7 ~]$ mkdir -p /u01/dbbak/script
[oracle@OEL7 ~]$ cd /u01/dbbak
[oracle@OEL7 ~]$ chown -R oracle:oinstall script

[oracle@OEL7 ~]$ mkdir -p /u01/dbbak/db
[oracle@OEL7 ~]$ mkdir -p /u01/dbbak/arch
[oracle@OEL7 ~]$ cd /u01/dbbak
[oracle@OEL7 ~]$ chown -R oracle:oinstall db
[oracle@OEL7 ~]$ chown -R oracle:oinstall arch
1.2 编辑脚本
[oracle@OEL7 ~]$ vi /u01/dbbak/script/rman_full.sh

export ORACLE_HOME=/u01/app/oracle/product/19.0.0/dbhome_1
export ORACLE_SID=prod
dt=`date '+%Y%m%d_%H%M%S'`
/u01/app/oracle/product/19.3.0/dbhome_1/bin/rman target / cmdfile=/u01/dbbak/script/backup.sh log=/u01/dbbak/log/log_$dt.log append
[oracle@OEL7 ~]$ vi /u01/dbbak/script/backup.sh

run{
allocate channel c1 type disk;   
allocate channel c2 type disk;   
allocate channel c3 type disk;
allocate channel c4 type disk;
backup as compressed backupset database format '/u01/dbbak/db/DB%U.bkp' plus archivelog format '/u01/dbbak/arch/ARCH%U.bkp' delete all input;
release channel c1;  
release channel c2;  
release channel c3;
release channel c4;
report obsolete;
crosscheck copy;
crosscheck archivelog all;
delete noprompt obsolete;
crosscheck backup;
delete noprompt expired backup;
}
quit;
EOF
1.3 脚本授权
[oracle@OEL7 ~]$ chmod 775 /u01/dbbak/script/backup.sh
[oracle@OEL7 ~]$ chmod 775 /u01/dbbak/script/rman_full.sh
1.4 执行脚本
1.5 定时任务
crontab -e 为编辑窗口

[oracle@OEL7 ~]$ crontab -l
0 2 * * * /u01/dbbak/script/rman_full.sh
1.6 备份删除
[oracle@OEL7 ~]$ rman target /

RMAN> show all;
--备份策略调整，备份保留7天
CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 7 DAYS;

--------------------------------------------------------

2.Oracle逻辑备份
2.1 生成目录
[oracle@OEL7 ~]$ mkdir -p /home/oracle/backup/dump
[oracle@OEL7 ~]$ mkdir -p /home/oracle/backup/tars

#使用expdp时需要先指定转储文件和日志文件所在的目录，可以通过如下命令实现
SQL> CREATE OR REPLACE DIRECTORY scott_backup as '/home/oracle/backup/dump';
SQL> grant read,write on directory scott_backup to public; 
2.2 备份脚本

[oracle@OEL7 ~]$ vi /home/oracle/backup/exp_backup.sh

#!/bin/bash
#Oracle 环境变量
NLS_LANG=AMERICAN_AMERICA.AL32UTF8
ORACLE_SID=prod
ORACLE_BASE=/opt/oracle
ORACLE_HOME=/opt/oracle/11g
PATH=$PATH:$ORACLE_HOME/bin:$HOME/bin
export ORACLE_SID ORACLE_BASE ORACLE_HOME NLS_LANG PATH

#获取时间戳
#dump生成时间
export BAKUPTIME=`date +%Y%m%d%H%M%S`
#压缩文件存放目录
export DATA_DIR=/home/oracle/backup/dump
export TAR_DIR=/home/oracle/backup/tars
cd $DATA_DIR     
echo "Starting bakup..."
echo "Bakup file path $DATA_DIR/scott_expdp_$BAKUPTIME.dmp"
#parallel=4 为并行度，对于备份大数据库有助于减少备份时间，但会增加CPU负载。
expdp scott/tiger directory=scott_backup dumpfile=scott_expdp_$BAKUPTIME.dump logfile=scott_expdp_$BAKUPTIME.log parallel=4
echo "Starting tar..."
echo "Tar file path $TAR_DIR/SCOTT_$BAKUPTIME.tar.gz"
tar -zcvf $TAR_DIR/scott_expdp_$BAKUPTIME.tar.gz scott_expdp*
echo "Bakup job is done!"
#历史dump文件保留7天
find  $DATA_DIR -type f -mtime +7 -exec rm -rf {} \;
2.3 定时任务
crontab -e 为编辑窗口

[oracle@OEL7 ~]$ crontab -l
0 3 * * * /home/oracle/backup/exp_backup.sh