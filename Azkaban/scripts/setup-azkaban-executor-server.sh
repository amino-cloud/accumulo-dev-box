#!/bin/bash
source /vagrant/scripts/common.sh

function setupAzkabanExecutorServer {
	echo "setting up azkaban executor server"
	CONF_DIR=$RESOURCES/azkaban-executor
	INSTALL_DIR=/usr/local/azkaban-executor-2.1
	tar -xzf $RESOURCE_AZKABAN_EXECUTOR_SERVER -C /usr/local
	mv /usr/local/azkaban-2.1 $INSTALL_DIR
	cp -f $CONF_DIR/azkaban.properties $INSTALL_DIR/conf
	cp -f $CONF_DIR/global.properties $INSTALL_DIR/conf
	cp -f $CONF_DIR/azkaban-users.xml $INSTALL_DIR/conf
	cp -f $CONF_DIR/azkaban-executor-start.sh $INSTALL_DIR/bin
	cp -f $CONF_DIR/azkaban-executor-shutdown.sh $INSTALL_DIR/bin
	mkdir /tmp/azkaban-executor
	setupJobTypePlugin
	setupHdfsViewerPlugin
	installMySqlConnector
}

function setupJobTypePlugin {
	echo "setting up azkaban job type plugin"
	tar -xzf $RESOURCE_AZKABAN_PLUGIN_JOBTYPES -C $INSTALL_DIR/plugins
	mv $INSTALL_DIR/plugins/azkaban-jobtype-2.1 $INSTALL_DIR/plugins/jobtypes
	rm -fr $INSTALL_DIR/plugins/jobtypes/hive-0.8.1
	rm -fr $INSTALL_DIR/plugins/jobtypes/pig-0.10.0
	rm -fr $INSTALL_DIR/plugins/jobtypes/pig-0.10.1
	rm -fr $INSTALL_DIR/plugins/jobtypes/pig-0.11.0
	rm -fr $INSTALL_DIR/plugins/jobtypes/pig-0.9.2
	cp -f $CONF_DIR/common.properties $INSTALL_DIR/plugins/jobtypes
	cp -f $CONF_DIR/commonprivate.properties $INSTALL_DIR/plugins/jobtypes
}

function setupHdfsViewerPlugin {
	echo "setting up azkaban hdfs viewer plugin"
	mkdir $INSTALL_DIR/plugins/viewer
	tar -xzf $RESOURCE_AZKABAN_PLUGIN_HDFS -C $INSTALL_DIR/plugins/viewer
	mv $INSTALL_DIR/plugins/viewer/azkaban-hdfs-viewer-2.1 $INSTALL_DIR/plugins/viewer/hdfs
}

function installMySqlConnector {
	cp /tmp/mysql-connector-java-5.1.29/mysql-connector-java-5.1.29-bin.jar $INSTALL_DIR/extlib
}

setupAzkabanExecutorServer