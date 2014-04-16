#!/bin/bash
source /vagrant/scripts/common.sh

function setupHadoop {
	export JAVA_HOME=/usr/local/java
	export HADOOP_PREFIX=/usr/local/hadoop
	
	echo "setting up hadoop"
	tar -xzf $RESOURCE_HADOOP -C /usr/local
	ln -s /usr/local/hadoop-2.3.0 /usr/local/hadoop
	
	echo "creating hadoop directories"
	mkdir /tmp/hadoop-namenode
	mkdir /tmp/hadoop-logs
	mkdir /tmp/hadoop-datanode
	
	echo "overwriting over hadoop files and more"
	cp -f $RESOURCE_HADOOP_CORE /usr/local/hadoop/etc/hadoop
	cp -f $RESOURCE_HADOOP_HDFS /usr/local/hadoop/etc/hadoop
	cp -f $RESOURCE_HADOOP_MAPRED /usr/local/hadoop/etc/hadoop
	cp -f $RESOURCE_HADOOP_YARN /usr/local/hadoop/etc/hadoop
	cp -f $RESOURCE_HADOOP_SLAVES /usr/local/hadoop/etc/hadoop
	cp -f $RESOURCE_HADOOP_HENV /usr/local/hadoop/etc/hadoop
	cp -f $RESOURCE_HADOOP_YENV /usr/local/hadoop/etc/hadoop
	cp -f $RESOURCE_HADOOP_PROFILE /etc/profile.d
	cp -f $RESOURCE_HADOOP_SERVICE /etc/init.d
	
	echo "modifying permissions on local file system"
	chown -fR vagrant /tmp/hadoop-namenode
    chown -fR vagrant /tmp/hadoop-logs
    chown -fR vagrant /tmp/hadoop-datanode
	chown -fR vagrant /usr/local/hadoop-2.3.0
	
	echo "setting up hadoop service"
	chmod 777 /etc/init.d/hadoop
	chkconfig --level 2345 hadoop on
	
	echo "formatting namenode"
	/usr/local/hadoop/bin/hdfs namenode -format azkaban
	
	echo "starting hadoop service"
	service hadoop start
	
	echo "initializing hdfs /tmp dir"
	$HADOOP_PREFIX/bin/hdfs --config $HADOOP_PREFIX/etc/hadoop dfs -mkdir /tmp
	$HADOOP_PREFIX/bin/hdfs --config $HADOOP_PREFIX/etc/hadoop dfs -chmod -R 777 /tmp
}

setupHadoop