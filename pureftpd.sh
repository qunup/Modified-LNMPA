#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    printf "Error: You must be root to run this script!\n"
    exit 1
fi
clear
printf "=========================================================================\n"
printf "Pureftpd for LNMP V0.8  ,  Written by Licess \n"
printf "=========================================================================\n"
printf "LNMP is a tool to auto-compile & install Nginx+MySQL+PHP on Linux \n"
printf "This script is a tool to install pureftpd for lnmp \n"
printf "\n"
printf "For more information please visit http://www.lnmp.org \n"
printf "\n"
printf "Usage: ./pureftpd.sh \n"
printf "=========================================================================\n"
cur_dir=$(pwd)

#set mysql root password

	mysqlrootpwd=""
	read -p "Please input your root password of mysql:" mysqlrootpwd
	if [ "$mysqlrootpwd" = "" ]; then
		echo "MySQL root password can't be NULL!"
		exit 1
	else
	echo "==========================="
	echo "Your root password of mysql was:$mysqlrootpwd"
	echo "==========================="
	fi

#set password of User manager

	ftpmanagerpwd=""
	read -p "Please input password of User manager:" ftpmanagerpwd
	if [ "$ftpmanagerpwd" = "" ]; then
		echo "password of User manager can't be NULL!"
		exit 1
	else
	echo "==========================="
	echo "Your password of User manager was:$ftpmanagerpwd"
	echo "==========================="
	fi

#set password of mysql ftp user

	mysqlftppwd=""
	read -p "Please input password of mysql ftp user:" mysqlftppwd
	if [ "$mysqlftppwd" = "" ]; then
		echo "password of User manager can't be NULL!"
		echo "script will randomly generated a password!"
		mysqlftppwd=`cat /dev/urandom | head -1 | md5sum | head -c 8`
	echo "==========================="
	echo "Your password of mysql ftp user was:$mysqlftppwd"
	echo "==========================="
	fi

	get_char()
	{
	SAVEDSTTY=`stty -g`
	stty -echo
	stty cbreak
	dd if=/dev/tty bs=1 count=1 2> /dev/null
	stty -raw
	stty echo
	stty $SAVEDSTTY
	}
	echo ""
	echo "Press any key to start install Pure-FTPd..."
	char=`get_char`

echo "Start download files..."
wget -c http://soft.vpser.net/ftp/pure-ftpd/pure-ftpd-1.0.35.tar.gz
wget -c http://soft.vpser.net/ftp/pure-ftpd/User_manager_for-PureFTPd_v2.1_CN.zip

cp /usr/local/mysql/lib/mysql/*.* /usr/lib/

echo "Start install pure-ftpd..."
tar zxvf pure-ftpd-1.0.35.tar.gz
cd pure-ftpd-1.0.35/
./configure --prefix=/usr/local/pureftpd CFLAGS=-O2 \
--with-mysql=/usr/local/mysql \
--with-quotas \
--with-cookie \
--with-virtualhosts \
--with-virtualroot \
--with-diraliases \
--with-sysquotas \
--with-ratios \
--with-altlog \
--with-paranoidmsg \
--with-shadow \
--with-welcomemsg  \
--with-throttling \
--with-uploadscript \
--with-language=simplified-chinese

make && make install

echo "Copy configure files..."
cp configuration-file/pure-config.pl /usr/local/pureftpd/sbin/
chmod 755 /usr/local/pureftpd/sbin/pure-config.pl
cp $cur_dir/conf/pureftpd-mysql.conf /usr/local/pureftpd/
cp $cur_dir/conf/pure-ftpd.conf /usr/local/pureftpd/

echo "Modify parameters of pureftpd configures..."
sed -i 's/127.0.0.1/localhost/g' /usr/local/pureftpd/pureftpd-mysql.conf
sed -i 's/tmppasswd/'$mysqlftppwd'/g' /usr/local/pureftpd/pureftpd-mysql.conf
cp $cur_dir/conf/script.mysql /tmp/script.mysql
sed -i 's/mysqlftppwd/'$mysqlftppwd'/g' /tmp/script.mysql
sed -i 's/ftpmanagerpwd/'$ftpmanagerpwd'/g' /tmp/script.mysql

echo "Import pureftpd database..."
/usr/local/mysql/bin/mysql -u root -p$mysqlrootpwd -h localhost < /tmp/script.mysql

rm -f /tmp/script.mysql

echo "Install GUI User manager for PureFTPd..."
cd $cur_dir
unzip User_manager_for-PureFTPd_v2.1_CN.zip
mv ftp /home/wwwroot/
chmod 777 -R /home/wwwroot/ftp/
chown www -R /home/wwwroot/ftp/

echo "Modify parameters of GUI User manager for PureFTPd..."
sed -i 's/English/Chinese/g' /home/wwwroot/ftp/config.php
sed -i 's/tmppasswd/'$mysqlftppwd'/g' /home/wwwroot/ftp/config.php
sed -i 's/myipaddress.com/127.0.0.1/g' /home/wwwroot/ftp/config.php
mv /home/wwwroot/ftp/install.php /home/wwwroot/ftp/install.php.bak

cd $cur_dir
cp pureftpd /root/pureftpd
chmod +x /root/pureftpd

wget -c http://soft.vpser.net/lnmp/ext/init.d.pureftpd
cp init.d.pureftpd /etc/init.d/pureftpd
chmod +x /etc/init.d/pureftpd

if [ -s /etc/debian_version ]; then
update-rc.d pureftpd defaults
fi

if [ -s /etc/redhat-release ]; then
echo "/etc/init.d/pureftpd start" >>/etc/rc.local
fi

clear
printf "=======================================================================\n"
printf "Starting pureftpd...\n"
/etc/init.d/pureftpd start
printf "=======================================================================\n"
printf "Install Pure-FTPd completed,enjoy it!\n"
printf "Now you enter http://youdomain.com/ftp/ in you Web Browser to manager FTP users\n"
printf "Your password of User manager was:$ftpmanagerpwd\n"
printf "Your password of mysql ftp user was:$mysqlftppwd\n"
printf "=======================================================================\n"
printf "Install Pure-FTPd for LNMP V0.8  ,  Written by Licess \n"
printf "=======================================================================\n"
printf "LNMP is a tool to auto-compile & install Nginx+MySQL+PHP on Linux \n"
printf "This script is a tool to install Pure-FTPd for lnmp \n"
printf "\n"
printf "For more information please visit http://www.lnmp.org \n"
printf "=======================================================================\n"
