#!/bin/bash
yum -y install httpd mariadb mariadb-server  gcc gcc-c++ mysql-devel php php-mysql php-common php-gd php-mbstring php-mcrypt php-devel php-xml php-bcmath
systemctl start mariadb;systemctl enable mariadb
systemctl start httpd;systemctl enable httpd
useradd zabbix
cd /root
tar -xf zabbix-3.2.3.tar.gz
cd zabbix-3.2.3
./configure --prefix=/usr/local/zabbix --enable-server --enable-agent --with-mysql
make && make install
cp -r /root/zabbix-3.2.3/frontends/php  /var/www/html/zabbix
chown -R apache.apache /var/www/html/zabbix/
mkdir /var/log/zabbix
chown zabbix.zabbix /var/log/zabbix
ln -s /usr/local/zabbix/etc /etc/zabbix
ln -s /usr/local/zabbix/bin/* /usr/bin/
ln -s /usr/local/zabbix/sbin/* /usr/sbin/
cp /root/zabbix-3.2.3/misc/init.d/fedora/core/zabbix_* /etc/init.d/
cp -r /root/zabbix-3.2.3/frontends/php /var/www/html/zabbix
chown -R apache.apache /var/www/html/zabbix
## change /etc/init.d/zabbix_server
sed -i "/BASEDIR=/s@/usr/local@&/zabbix@"  /etc/init.d/zabbix_server
## change /etc/init.d/zabbix_agentd
sed -i "/BASEDIR=/s@/usr/local@&/zabbix@"  /etc/init.d/zabbix_agentd
## change /etc/serveices
sed -i "/zabbix-trapper/s@trapper@server@"  /etc/services
## change /etc/php.ini
sed -i "/post_max_size =/c post_max_size = 16M"  /etc/php.ini
sed -i "/max_execution_time =/c max_execution_time = 300"  /etc/php.ini
sed -i "/max_input_time =/c max_input_time = 300"  /etc/php.ini
sed -i "/date.timezone/c date.timezone = Asia/Shanghai"  /etc/php.ini
## change zabbix_server.conf
sed -i "/^DBName=/c DBName=zabbix"  /etc/zabbix/zabbix_server.conf
sed -i "/^DBUser=/c DBUser=zabbix"  /etc/zabbix/zabbix_server.conf
sed -i "/DBPassword=/c DBPassword=zabbix"  /etc/zabbix/zabbix_server.conf
sed -i "/^LogFile=/s@/tmp/@/var/log/zabbix/@"  /etc/zabbix/zabbix_server.conf
## change /etc/zabbix/zabbix_agentd.conf
sed -i "/^Server=/c Server=127.0.0.1,192.168.47.203"  /etc/zabbix/zabbix_agentd.conf
sed -i "/^ServerActive=/c ServerActive=192.168.47.203:10051"  /etc/zabbix/zabbix_agentd.conf
sed -i "/^LogFile=/s@/tmp@/var/log/zabbix@"  /etc/zabbix/zabbix_agentd.conf
sed -i "/UnsafeUserParameters=/c UnsafeUserParameters=1"  /etc/zabbix/zabbix_agentd.conf
echo "
##############
配置数据库
  创建库: zabbix
  授权用户: zabbix
  授权密码: zabbix
  导入数据: 
	cd /root/zabbix-3.2.3/database/mysql
        mysql -u zabbix -pzabbix zabbix < schema.sql 
	mysql -u zabbix -pzabbix zabbix < images.sql 
	mysql -u zabbix -pzabbix zabbix < data.sql
启动zabbix_server
	chkconfig zabbix_server on
	service zabbix_server start
启动zabbix_agentd
	chkconfig zabbix_agentd on
	service zabbix_agentd start
重启服务
	systemctl restart mariadb
	systemctl restart httpd
##############
" ; exit 

