1.PostgreSQL逻辑备份
1.1 备份脚本
vi /data/script_name.sh 

#!/bin/bash
 
# PostgreSQL数据库相关信息
db_host="localhost"
db_port="5432"
db_name="database_name"
db_user="database_user"
db_password="database_password"
 
# 备份存储目录
backup_dir="/data/backup/folder"
 
# 保留备份的天数
retention_days=7
 
# 创建备份目录
mkdir -p $backup_dir
 
# 备份文件名
backup_file="$backup_dir/backup_$(date +'%Y%m%d%H%M%S').sql"
 
# 执行备份
PGPASSWORD=$db_password 
pg_dump -h $db_host -p $db_port -U $db_user -F c -b -v -f "$backup_file" $db_name
 
if [ $? -eq 0 ]; then
    echo "数据库备份成功: $backup_file"
 
    # 删除旧的备份文件
    find $backup_dir -name "backup_*.sql" -type f -mtime +$retention_days -exec rm -f {} \;
else
    echo "数据库备份失败."
fi
1.2 定时任务
在命令行输入:
#crontab -e
#每天定时凌晨2点定时任务
0 2 * * * /data/script_name.sh
1.3 备份恢复
--恢复
drop database jmedb;
create database jmedb;;
psql --file=jmedb.sql   --先查看可否有创建数据库的语句 
psql --dbname=db2 --file=jmedb.sql   --先查看可否有创建数据库的语句


--------------------------------------------------------
2.PostgreSQL物理备份
2.1 备份脚本
#!/bin/bash

source /home/postgres/.bash_profile

DATE=`date +%Y%m%d`;
PG_HOME=/home/postgres
BACK_LOG=/home/postgres/log/pg_rman_${DATE}.log

#START BACKUP
echo "START BACKUP" > $BACK_LOG
#执行备份命令
pg_rman backup --backup-mode=full -B /rmanbk >> $BACK_LOG
#备份集校验
pg_rman validate >> $BACK_LOG
#检查备份是否成功
error_num=`pg_rman show | awk 'BEGIN{n=0}{if(NR > 3 && $8 != "OK")n++}END{print n}'`
if [ $error_num > 0 ];then
    message="Postgres 数据库服务器${hostname}在${DATE}备份失败" 
    echo $message
fi
#清理无效备份集
pg_rman purge >> $BACK_LOG
echo "BACKUP  END" >> $BACK_LOG
2.2 备份恢复
--原地恢复,使用新的$PGDATA恢复
pg_ctl stop 
rm -rf /postgresql/pgdata/    
pg_rman restore -B /rmanbk

-- 检查配置文件是否有问题，若无问题则可以启动PG
pg_ctl start

--检验数据是否正确
启动PG后，会删除recovery.signal文件