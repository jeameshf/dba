# 1.install_database
数据库一键安装脚本 

-----------------------------------------------------
OracleShellInstall.sh

【脚本说明】

1、下载19C安装包LINUX.X64_193000_db_home.zip后上传到/opt目录下

2、ISO系统镜像需要挂载，后期用于YUM

3、MY_SERVER_IP、MY_HOSTNAME根据自己环境修改

4、MY_ORA_SID为实例名、MY_ORA_MEMORY为分配到内存大小，根据实际情况修改

5、createAsContainerDatabase=TRUE表示容器数据库，改为false后就是非容器

直接执行脚本，自动化安装，本脚本适用于Linux7,其他操作系统可能涉及yum的配置不同，请自行修改

-----------------------------------------------------
MySQLShellInstall.sh

【脚本说明】

1、下载MySQL二进制安装包后上传到/opt目录下

2、ISO系统镜像需要挂载，后期用于YUM

3、脚本中最后请修改root密码

4、脚本中配置了二进制自启动数据库到服务

直接执行脚本，自动化安装，本脚本适用于Linux7,其他操作系统可能涉及yum的配置不同，请自行修改

-----------------------------------------------------
PostgreSQLShellInstall.sh

【脚本说明】

1、下载PG源码安装包后上传到/opt目录下

2、ISO系统镜像需要挂载，后期用于YUM

3、MY_SERVER_IP、MY_HOSTNAME根据自己环境修改

4、PG_VERSION为版本号，如果其他版本请更改

直接执行脚本，自动化安装，本脚本适用于Linux7,其他操作系统可能涉及yum的配置不同，请自行修改

-----------------------------------------------------
MssqlShellInstall.sh

【脚本说明】

1、下载SQL server RPM包上传到/opt目录下

2、建议服务器内存需≥4GB，建议swap空间≥2GB

3.SQL server RPM可以通过官网下载
https://learn.microsoft.com/zh-cn/

直接执行脚本，自动化安装，本脚本适用于Linux7,其他操作系统可能涉及yum的配置不同，请自行修改


# 2.backup_database

全栈适配MySQL/Oracle/PostgreSQL/SQL server，3分钟极速部署，传统耗时砍掉95%，老板连夜要求全员掌握。


