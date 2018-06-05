#!/bin/bash
yum -y install gcc gcc-c++
useradd zabbix
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


