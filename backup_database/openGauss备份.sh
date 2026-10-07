1 备份脚本
vi /home/omm/backup.sh

# database dump shell
# you should change the GAUSSHOME GAUSSPORT GAUSSDATA DUMP_USER DUMP_PASSWORD
#!/bin/bash
source /etc/profile
source /home/omm/.bash_profile
export GAUSSHOME=/opt/gaussdb/app
export GAUSSPORT=26000
export GAUSSDATA=/gaussdb/data/dn1
export PATH=$PGHOME/bin:$PATH
DUMP_USER=ysla
DUMP_PASSWORD='jeames007@HW'
CUR_DATE=`date "+%Y-%m-%d-%H%M"`
dbnamelist=`cat db.txt`
 
#Loading DBLIST
gsql -p ${GAUSSPORT} postgres -c "select datname from pg_database where datname not in ('template1','template0','postgres')" -t | grep -v '^$' >db.txt
 
#save directory
SAVE_BASE_DIR="/gaussdb/dump_dir"
DAT_FILE_DIR="${SAVE_BASE_DIR}/${CUR_DATE}"
if [ -d ${DAT_FILE_DIR} ]
 then :
 else
 mkdir -p ${DAT_FILE_DIR}
fi
# The real backup step!
echo "`date "+%Y-%m-%d-%H%M"` begin backup db "
for dbname in ${dbnamelist}
do
gs_dump -E UTF8 ${dbname} -U ${DUMP_USER} -W ${DUMP_PASSWORD} -p ${GAUSSPORT} -F p -f ${DAT_FILE_DIR}/${dbname}_${CUR_DATE}.sql
gs_dumpall -l ${dbname} -U ${DUMP_USER} -W ${DUMP_PASSWORD} -p ${GAUSSPORT} -g -f ${DAT_FILE_DIR}/global_data_${dbname}_${CUR_DATE}.sql
done
tar -cjvf ${DAT_FILE_DIR}.tar.gz /${DAT_FILE_DIR} --remove-files
echo "`date "+%Y-%m-%d-%H%M"` end backup db "
2.定时任务
在命令行输入:
#crontab -e
30 02 * * * sh /home/omm/backup.sh
3.备份清理
每天都进行备份，如果备份天数过多不清理，
可能使目录打满，因此需要添加备份清理策略
在命令行输入:
#crontab -e
30 03 * * * find /gaussdb/dump_dir  -not -path '*/\.*' -mtime +30  -type f -name *.tar.gz -exec rm -rf {} \;"