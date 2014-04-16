#!/bin/bash
source /vagrant/scripts/common.sh

function setupAzkabanWebServer {
	CONF_DIR=$RESOURCES/azkaban-web
	INSTALL_DIR=/usr/local/azkaban-web-2.1
	echo "setting up azkaban web server"
	tar -xzf $RESOURCE_AZKABAN_WEB_SERVER -C /usr/local
	mv /usr/local/azkaban-2.1 $INSTALL_DIR
	cp -f $CONF_DIR/azkaban.properties $INSTALL_DIR/conf
	cp -f $CONF_DIR/global.properties $INSTALL_DIR/conf
	cp -f $CONF_DIR/azkaban-users.xml $INSTALL_DIR/conf
	cp -f $CONF_DIR/keystore /etc/keystore
	cp -f $CONF_DIR/azkaban-web-start.sh $INSTALL_DIR/bin
	installMySqlConnector
	mkdir /tmp/azkaban-web
}

function installMySqlConnector {
	tar -xzf $RESOURCE_MYSQL_CONNECTOR -C /tmp
	cp /tmp/mysql-connector-java-5.1.29/mysql-connector-java-5.1.29-bin.jar $INSTALL_DIR/extlib
}

setupAzkabanWebServer