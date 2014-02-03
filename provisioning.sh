#!/bin/bash

echo "Updating the system and installing curl and python-software properties..."
sudo sed -i 's/us.archive.ubuntu.com/mirror.umd.edu/' /etc/apt/sources.list
sudo apt-get -q update
sudo apt-get -q install curl python-software-properties -y

echo "Installing Sun Java..."
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update
echo debconf shared/accepted-oracle-license-v1-1 select true | \
  sudo /usr/bin/debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | \
  sudo /usr/bin/debconf-set-selections
sudo apt-get install -y oracle-java7-installer

echo "Running updates..."


echo "Setting up environment..."
cat >> /home/vagrant/.bashrc <<EOF
export JAVA_HOME=/usr/lib/jvm/java-7-oracle/
export HADOOP_HOME=/home/vagrant/hadoop-0.20.2-cdh3u3
export ZOOKEEPER_HOME=/home/vagrant/zookeeper-3.3.4-cdh3u3
export PATH=$PATH:/home/vagrant/hadoop-0.20.2-cdh3u3/bin:/home/vagrant/accumulo-1.4.3/bin
EOF
export JAVA_HOME=/usr/lib/jvm/java-7-oracle/
export HADOOP_HOME=/home/vagrant/hadoop-0.20.2-cdh3u3
export ZOOKEEPER_HOME=/home/vagrant/zookeeper-3.3.4-cdh3u3
export PATH=$PATH:/home/vagrant/hadoop-0.20.2-cdh3u3/bin:/home/vagrant/accumulo-1.4.3/bin

echo "Acquiring archives..."
cd /home/vagrant
echo "- Hadoop"
curl -O -L http://archive.cloudera.com/cdh/3/hadoop-0.20.2-cdh3u3.tar.gz
echo "- Zookeeper"
curl -O -L http://archive.cloudera.com/cdh/3/zookeeper-3.3.4-cdh3u3.tar.gz
echo "- Accumulo"
curl -O -L http://www.gtlib.gatech.edu/pub/apache/accumulo/1.4.4/accumulo-1.4.4-dist.tar.gz

echo "Extracting archives..."
tar -zxf hadoop-0.20.2-cdh3u3.tar.gz
tar -zxf zookeeper-3.3.4-cdh3u3.tar.gz
tar -zxf accumulo-1.4.4-dist.tar.gz

echo "Configuring Hadoop..."
ssh-keygen -t rsa -f /home/vagrant/.ssh/id_rsa -N ''
cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
ssh-keyscan localhost >> /home/vagrant/.ssh/known_hosts
cat >> hadoop-0.20.2-cdh3u3/conf/hadoop-env.sh <<EOF
export JAVA_HOME=/usr/lib/jvm/java-7-oracle/
EOF
cat > hadoop-0.20.2-cdh3u3/conf/core-site.xml <<EOF
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<!-- Put site-specific property overrides in this file. -->

<configuration>
  <property>
    <name>fs.default.name</name>
    <value>hdfs://localhost:8020</value>
  </property>
  <property>
    <name>mapred.child.java.opts</name>
    <value>-Xmx1024m</value>
  </property>
  <property>
    <name>analyzer.class</name>
    <value>org.apache.lucene.analysis.WhitespaceAnalyzer</value>
  </property>
  <property> 
    <name>hadoop.proxyuser.vagrant.hosts</name> 
    <value>*</value> 
  </property> 

  <property> 
    <name>hadoop.proxyuser.vagrant.groups</name> 
    <value>*</value> 
  </property> 
</configuration>

EOF
cat > hadoop-0.20.2-cdh3u3/conf/mapred-site.xml <<EOF
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<!-- Put site-specific property overrides in this file. -->

<configuration>
   <property>
       <name>mapred.job.tracker</name>
       <value>localhost:8021</value>
   </property>
   <property>
       <name>mapred.child.java.opts</name>
       <value>-Xmx2048m</value>
   </property>
</configuration>

EOF
hadoop-0.20.2-cdh3u3/bin/hadoop namenode -format

echo "Starting Hadoop..."
hadoop-0.20.2-cdh3u3/bin/start-all.sh

echo "Configuring Zookeeper..."
sudo mkdir /var/zookeeper
sudo chown vagrant:vagrant /var/zookeeper

echo "Running Zookeeper..."
zookeeper-3.3.4-cdh3u3/bin/zkServer.sh start

echo "Configuring Accumulo..."
cp accumulo-1.4.4/conf/examples/1GB/standalone/* accumulo-1.4.4/conf/

cat > ~/accumulo-1.4.4/conf/masters <<EOF
accumulo-dev-box
EOF

cat > ~/accumulo-1.4.4/conf/slaves <<EOF
accumulo-dev-box
EOF

sed -i 's/>DEFAULT</>password</' accumulo-1.4.4/conf/accumulo-site.xml
accumulo-1.4.4/bin/accumulo init --clear-instance-name <<EOF
accumulo
password
password
EOF

echo "Deploying the Amino Accumulo iterator"
cp /vagrant/Amino/amino-accumulo-iterators* accumulo-1.4.4/lib/ext/

echo "Starting Accumulo..."
accumulo-1.4.4/bin/start-all.sh

echo "Adding authorizations"
accumulo-1.4.4/bin/accumulo shell -u root -p password -e "setauths -s U"

echo "Creating the HDFS structures for the number example"
hadoop fs -mkdir /amino/numbers/config
hadoop fs -mkdir /amino/numbers/in
hadoop fs -mkdir /amino/numbers/out
hadoop fs -mkdir /amino/numbers/working
hadoop fs -copyFromLocal /vagrant/Amino/NumberLoader.xml /amino/numbers/config
hadoop fs -copyFromLocal /vagrant/Amino/AminoDefaults.xml /amino/numbers/config
hadoop fs -copyFromLocal /vagrant/Amino/numbers-* /amino/numbers/in


echo 'Done!'



