#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh
. ./environment.sh

#send a message
verbose "Configuring PHP"

#add the repository
if [ ."$os_name" = ."Ubuntu" ]; then
        #16.10.x - */yakkety/
        #16.04.x - */xenial/
        #14.04.x - */trusty/
        if [ ."$os_codename" = ."trusty" ]; then
                which add-apt-repository || apt-get install -y software-properties-common
                LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
        fi
elif [ ."$cpu_architecture" = ."arm" ]; then
	#Pi2 and Pi3 Raspbian
	#Odroid
	if [ ."$os_codename" = ."stretch" ]; then
	      php_version=7.2
	else
	      php_version=5.6
	fi
	apt-get -y install apt-transport-https lsb-release ca-certificates
	wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
	sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
else
        #9.x - */stretch/
        #8.x - */jessie/
	apt-get -y install apt-transport-https lsb-release ca-certificates
	wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
	sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
fi
apt-get update -y

#install dependencies
apt-get install -y nginx
if [ ."$php_version" = ."5.6" ]; then
        apt-get install -y php5 php5-cli php5-fpm php5-pgsql php5-sqlite php5-odbc php5-curl php5-imap php5-mcrypt php5-gd
fi
if [ ."$php_version" = ."7.0" ]; then
        apt-get install -y php7.0 php7.0-cli php7.0-fpm php7.0-pgsql php7.0-sqlite3 php7.0-odbc php7.0-curl php7.0-imap php7.0-mcrypt php7.0-xml php7.0-gd
fi
if [ ."$php_version" = ."7.1" ]; then
        apt-get install -y php7.1 php7.1-cli php7.1-fpm php7.1-pgsql php7.1-sqlite3 php7.1-odbc php7.1-curl php7.1-imap php7.1-mcrypt php7.1-xml php7.1-gd
fi
if [ ."$php_version" = ."7.2" ]; then
        apt-get install -y php7.2 php7.2-cli php7.2-fpm php7.2-pgsql php7.2-sqlite3 php7.2-odbc php7.2-curl php7.2-imap php7.2-xml php7.2-gd
	apt-get install -y php7.2-mcrypt
fi

#update config if source is being used
if [ ."$php_version" = ."5" ]; then
        verbose "version 5.x"
        php_ini_file='/etc/php5/fpm/php.ini'
fi
if [ ."$php_version" = ."7.0" ]; then
        verbose "version 7.0"
        php_ini_file='/etc/php/7.0/fpm/php.ini'
fi
if [ ."$php_version" = ."7.1" ]; then
        verbose "version 7.1"
        php_ini_file='/etc/php/7.1/fpm/php.ini'
fi
if [ ."$php_version" = ."7.2" ]; then
        verbose "version 7.2"
        php_ini_file='/etc/php/7.2/fpm/php.ini'
fi
sed 's#post_max_size = .*#post_max_size = 80M#g' -i $php_ini_file
sed 's#upload_max_filesize = .*#upload_max_filesize = 80M#g' -i $php_ini_file

#restart php-fpm
#systemd
if [ ."$php_version" = ."5.6" ]; then
        systemctl restart php5-fpm
fi
if [ ."$php_version" = ."7.0" ]; then
        systemctl restart php7.0-fpm
fi
if [ ."$php_version" = ."7.1" ]; then
        systemctl restart php7.1-fpm
fi
if [ ."$php_version" = ."7.2" ]; then
        systemctl restart php7.2-fpm
fi

#init.d
#/usr/sbin/service php5-fpm restart
#/usr/sbin/service php7.0-fpm restart
