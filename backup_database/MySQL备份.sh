1.MySQL逻辑全｜增备份
1.1 开启binlog日志
binlog日志默认不开启，修改参数后重启MySQL数据库
mysql> show variables like '%log_bin%';

# vim /etc/my.cnf
log_bin=ON
log_bin_basename=/home/mysql/mysql-bin
log_bin_index=/home/mysql/mysql-bin.index
## 参数说明
log_bin：开启binlog日志文件，默认值为OFF。
log_bin_basename：binlog日志的基本文件名。MySQL会在该文件名后追加标识来表示每一个binlog文件。
log_bin_index：binlog文件的索引文件，管理所有的binlog文件。
1.2 全备脚本
# mkdir -p /home/mysql/daily
# mkdir -p /home/mysql/backup
# vi /home/mysql/Mysql-FullyBak.sh

#mysqldump to Fully backup mysql data per week!
source /etc/profile
BakDir=/home/mysql/backup
LogFile=/home/mysql/backup/bak.log
Date=`date +%Y%m%d`
Begin=`date +"%Y年%m月%d日 %H:%M:%S"`
cd $BakDir
DumpFile=$Date.sql
GZDumpFile=$Date.sql.tgz
/usr/bin/mysqldump -uroot -proot --quick --events --databases wmp --flush-logs --delete-master-logs --single-transaction >$DumpFile
/bin/tar -zvcf $GZDumpFile $DumpFile
/bin/rm $DumpFile
oldDate=`date -d '7 days ago' +%Y%m%d`
oldBakFile=${oldDate}".sql.tgz"
/bin/rm $oldBakFile
Last=`date +"%Y年%m月%d日 %H:%M:%S"`
echo 开始:$Begin 结束:$Last $GZDumpFile succ >> $LogFile
cd $BakDir/daily
/bin/rm -f *
1.3 增备脚本
# vi /home/mysql/Mysql-DailyBak.sh
#use cp to bakup mysql data everyday!
source /etc/profile
BakDir=/home/mysql/backup/daily
BinDir=/home/mysql/mysql-bin
LogFile=/home/mysql/backup/bak.log
BinFile=/home/mysql/mysql-bin/mysql-bin.index
/usr/bin/mysqladmin -uroot -proot flush-logs
Counter=`wc -l $BinFile |awk '{print $1}'`  
#产生新的mysql-bin.00000*文件
NextNum=0
#比对$Counter和￥NextNum这两个值来确定文件是不是最新的
for file in `cat $BinFile`
do
     base=`basename $file`
     #basename用于截取mysql-bin.00000*文件名，去掉./mysql-bin.000005前面的./
     NextNum=`expr $NextNum + 1`
     if [[ $NextNum -eq $Counter ]]
     then
        echo $base skip! >> $LogFile
      else
        dest=$BakDir/$base
         if(test -e $dest)
        #test -e用于检测目标文件是否存在，存在就写exist!到$LogFile去
         then
               echo $base exist! >> $LogFile
         else
                cp $BinDir/$base $BakDir
                echo $base copying >> $LogFile
          fi
fi
done
1.4 定时任务
在命令行输入:
#crontab -e
添加相应的任务，wq存盘退出
#每个星期日凌晨3:00执行完全备份脚本
0 3 * * 0 /bin/bash -x /home/mysql/Mysql-FullyBak.sh >/dev/null 2>&1
#周一到周六凌晨3:00做增量备份
0 3 * * 1-6 /bin/bash -x /home/mysql/Mysql-DailyBak.sh >/dev/null 2>&1


--------------------------------------------------------

2.MySQL PXB全/增备份
2.1 备份脚本
vi /home/mysql/scripts/backup.sh

#!/bin/bash

echo ""
START_TIME=`date`
echo "############## backup start at $START_TIME ##############"
echo ""
###you need install xtrabackup!###
# Set env
source /home/mysql/.bash_profile
which xtrabackup
# Database Info
DB_USER="root"
DB_PASS="jeames@123"
CONF="/data/mysqldb/conf/mysql.conf"
SOCKET="/data/mysqldb/socket/mysql.sock"
BAK_BASE="/db_bak/mysql_bak/mysql"
DATE=`date +%F`
YESTERDAY=`date +%F -d "-1 days"`
WEEK_DAY=`date +%w`
BAK_DIR=$BAK_BASE/$DATE-$WEEK_DAY
# Create Directory and backup
if [ "$WEEK_DAY" == "6"  ]; then
  xtrabackup --defaults-file=$CONF --socket=$SOCKET --backup --user=$DB_USER --password=$DB_PASS --target-dir=$BAK_DIR --compress
elif [ "$WEEK_DAY" == "0"  ]; then
  INCRE_BASE=$BAK_BASE/$YESTERDAY-6
  xtrabackup --defaults-file=$CONF --socket=$SOCKET --backup --user=$DB_USER --password=$DB_PASS --target-dir=$BAK_DIR --incremental-basedir=$INCRE_BASE --compress
else
  INCRE_BASE=$BAK_BASE/$YESTERDAY-$[WEEK_DAY-1]
  xtrabackup --defaults-file=$CONF --socket=$SOCKET --backup --user=$DB_USER --password=$DB_PASS --target-dir=$BAK_DIR --incremental-basedir=$INCRE_BASE --compress
fi
echo ""
END_TIME=`date`
echo "############## backup end at $END_TIME ##############"
echo ""
2.2 备份删除
vi  /home/mysql/scripts/cleanup.sh
#!/bin/bash

echo ""
START_TIME=`date`
echo "############## clean up start at $START_TIME ##############"
echo ""

find /db_bak/mysql_bak/mysql -maxdepth 1 -type d -mtime +30
find /db_bak/mysql_bak/mysql -maxdepth 1 -type d -mtime +30 -exec rm -rf {} \;

echo ""
END_TIME=`date`
echo "############## clean up end at $END_TIME ##############"
echo ""
2.3 定时任务
运行脚本
每天凌晨 4:10 分清理 30 天之前的备份，
每天 4:30 分使用 xtrabackup 进行备份，
注意只有周六是全备，其他时间均是增备。
#crontab -e
10 4 * * * /home/mysql/scripts/cleanup.sh >> /home/mysql/scripts/cleanup.log 2>&1
30 4 * * * /home/mysql/scripts/backup.sh >> /home/mysql/scripts/backup.log 2>&1