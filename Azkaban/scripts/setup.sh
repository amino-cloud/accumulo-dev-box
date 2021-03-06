#!/bin/bash
source /vagrant/scripts/common.sh
echo "starting setup..."

downloadFile $RESOURCE_AZKABAN_WEB_SERVER $URL_AZKABAN_WEB_SERVER
downloadFile $RESOURCE_AZKABAN_EXECUTOR_SERVER $URL_AZKABAN_EXECUTOR_SERVER
downloadFile $RESOURCE_AZKABAN_MYSQL_SCRIPTS $URL_AZKABAN_MYSQL_SCRIPTS
downloadFile $RESOURCE_AZKABAN_PLUGIN_HDFS $URL_AZKABAN_PLUGIN_HDFS
downloadFile $RESOURCE_AZKABAN_PLUGIN_JOBTYPES $URL_AZKABAN_PLUGIN_JOBTYPES
downloadFile $RESOURCE_AZKABAN_PLUGIN_YARN_SECURITY $URL_AZKABAN_PLUGIN_YARN_SECURITY
downloadFile $RESOURCE_MYSQL_CONNECTOR $URL_MYSQL_CONNECTOR
downloadFile $RESOURCE_HADOOP $URL_HADOOP