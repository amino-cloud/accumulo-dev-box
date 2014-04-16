#!/bin/bash
source /vagrant/scripts/common.sh

function setupMySql {
	echo "setting up mysql"
	sudo yum install mysql-server -y
	cp -f /vagrant/resources/mysql/my.cnf /etc/my.cnf
	sudo chkconfig mysqld on
	sudo /sbin/service mysqld start

	Q1="CREATE DATABASE IF NOT EXISTS azkaban;"
	Q2="CREATE USER 'azkaban'@'localhost' IDENTIFIED BY 'azkaban';"
	Q3="GRANT ALL PRIVILEGES ON *.* TO 'azkaban'@'localhost' WITH GRANT OPTION;"
	Q4="CREATE USER 'azkaban'@'%' IDENTIFIED BY 'azkaban';"
	Q5="GRANT ALL PRIVILEGES ON *.* TO 'azkaban'@'%' WITH GRANT OPTION;"
	Q6="FLUSH PRIVILEGES;"
	SQL="${Q1}${Q2}${Q3}${Q4}${Q5}${Q6}"
	mysql -uroot -e "$SQL"
}

function setupAzkabanDatabase {
	echo "setting up azkaban database"
	tar -xzf $RESOURCE_AZKABAN_MYSQL_SCRIPTS -C /tmp
	mysql -u azkaban -pazkaban -D azkaban < /tmp/azkaban-2.1/create-all-sql-2.1.sql
}

setupMySql
setupAzkabanDatabase