#!/bin/bash
yum -y install gcc gcc-c++
useradd -s /sbin/nologin zabbix
cd /root
if [ ! -f zabbix-3.2.3.tar.gz ];then
	echo "zabbix-3.2.3.tar.gz is not exist."
	exit 1
fi
tar -xf zabbix-3.2.3.tar.gz
cd zabbix-3.2.3
./configure --enable-agent --prefix=/usr/local/zabbix
make && make install
/usr/local/zabbix/etc/ /etc/zabbix
mkdir /var/log/zabbix
chown zabbix.zabbix /var/log/zabbix
cp /root/zabbix-3.2.3/misc/init.d/fedora/core/zabbix_agentd /etc/init.d/
chmod 755 /etc/init.d/zabbix_agentd
ln -s /usr/local/zabbix/etc /etc/zabbix
ln -s /usr/local/zabbix/bin/* /usr/bin/
ln -s /usr/local/zabbix/sbin/* /usr/sbin/
## change zabbix_agentd.conf
sed -i "/^Server=/c Server=127.0.0.1,192.168.47.203"  /etc/zabbix/zabbix_agentd.conf
sed -i "/^ServerActive=/c ServerActive=192.168.47.203:10051"  /etc/zabbix/zabbix_agentd.conf
sed -i "/^LogFile=/s@/tmp@/var/log/zabbix@"  /etc/zabbix/zabbix_agentd.conf
sed -i "/UnsafeUserParameters=/c UnsafeUserParameters=1"  /etc/zabbix/zabbix_agentd.conf
## change /etc/init.d/zabbix_agentd
sed -i "/^BASEDIR=/s@/usr/local@&/zabbix@"  /etc/init.d/zabbix_agentd
chkconfig zabbix_agentd on
service zabbix_agentd start

