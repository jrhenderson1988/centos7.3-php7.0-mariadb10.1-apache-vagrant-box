#!/bin/bash

echo ">>> Starting install script"

echo ">>> Changing default login directory to /home"
sudo mkdir /home/vagrant
echo "cd /home" >> /home/vagrant/.bash_profile

echo ">>> Adding Repositories"
sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
sudo touch /etc/yum.repos.d/MariaDB.repo
echo "[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.1/centos7-amd64
gpgkey = https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck = 1" | sudo tee /etc/yum.repos.d/MariaDB.repo

sudo yum -y install epel-release

echo ">>> Updating OS"
sudo yum -y update

echo ">>> Installing: Nano, Git"
sudo yum -y install nano git-core

echo ">>> Installing PHP 7.0"
sudo yum -y install php70w php70w-common php70w-mbstring php70w-mcrypt php70w-mysql php70w-pdo php70w-soap php70w-xml php70w-xmlrpc php70w-gd php70w-cli php70w-bcmath

echo ">>> Removing traces of MySQL"
sudo yum remove mysql-libs
sudo rm -Rf /var/lib/mysql

echo ">>> Installing MariaDB"
sudo yum -y install MariaDB-server MariaDB-client
sudo systemctl start mysqld.service
sudo chkconfig mysqld on
/usr/bin/mysqladmin -u root password 'root'

echo ">>> Installing phpMyAdmin"
cd /usr/share/
sudo wget https://files.phpmyadmin.net/phpMyAdmin/4.6.5.2/phpMyAdmin-4.6.5.2-english.tar.bz2
sudo tar -xvf phpMyAdmin-4.6.5.2-english.tar.bz2
sudo mv phpMyAdmin-4.6.5.2-english phpmyadmin
sudo cp /usr/share/phpmyadmin/config.sample.inc.php /usr/share/phpmyadmin/config.inc.php

echo ">>> Configuring Apache"
echo "
<Directory \"/home\">
    AllowOverride all
    Require all granted
</Directory>

<Directory "/usr/share/phpmyadmin">
    AllowOverride all
    Require all granted
</Directory>" | sudo tee -a /etc/httpd/conf/httpd.conf
echo "
<VirtualHost *:80>
  ServerName project.dev
  ServerAlias www.project.dev
  DocumentRoot /home/project/public
</VirtualHost>

<VirtualHost *:80>
  ServerName phpmyadmin.project.co.uk
  ServerAlias phpmyadmin.project.dev
  ServerAlias phpmyadmin.localhost
  DocumentRoot /usr/share/phpmyadmin
</VirtualHost>" | sudo tee /etc/httpd/conf.d/vhosts.conf
sudo systemctl start httpd.service
sudo chkconfig httpd on

echo ">>> Installing Composer"
cd /home
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('SHA384', 'composer-setup.php') === '669656bab3166a7aff8a7506b8cb2d1c292f042046c5a994c43155c0be6190fa0355160742ab2e1c88d40d5be660b410') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
sudo mv composer.phar /usr/local/bin/composer
