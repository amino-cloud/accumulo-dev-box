#!/bin/sh

set -o nounset
set -o errexit

ACCUMULO_VERSION=1.5.0
JDK_LOC=/usr/lib/jvm/java-7-openjdk-amd64/

# Install curl and Obtain the archives
echo "\n===================="
echo "Updating the system and installing curl and python-software properties..."
echo "===================="
sudo sed -i 's/us.archive.ubuntu.com/mirror.umd.edu/' /etc/apt/sources.list
sudo apt-get update
sudo apt-get install curl python-software-properties vim -y

# Install Java 7
echo "\n===================="
echo "Installing OpenJDK 7"
echo "===================="
sudo apt-get install -y openjdk-7-jdk

echo "\n===================="
echo "Setting up environment..."
echo "===================="
cat >> /home/vagrant/.bashrc <<EOF
export JAVA_HOME=$JDK_LOC
export HADOOP_HOME=/usr/lib/hadoop
export HADOOP_COMMON_HOME=/usr/lib/hadoop
export HADOOP_MAPRED_HOME=/usr/lib/hadoop-0.20-mapreduce
export HADOOP_HDFS_HOME=/usr/lib/hadoop-hdfs
export ZOOKEEPER_HOME=/usr/lib/zookeeper
export ACCUMULO_HOME=/home/vagrant/accumulo-$ACCUMULO_VERSION
EOF
export JAVA_HOME=$JDK_LOC
export HADOOP_HOME=/usr/lib/hadoop
export HADOOP_COMMON_HOME=/usr/lib/hadoop
export HADOOP_MAPRED_HOME=/usr/lib/hadoop-0.20-mapreduce
export HADOOP_HDFS_HOME=/usr/lib/hadoop-hdfs
export ZOOKEEPER_HOME=/usr/lib/zookeeper
export ACCUMULO_HOME=/home/vagrant/accumulo-$ACCUMULO_VERSION

echo "\n===================="
echo "Fetching CDH4"
echo "===================="
#wget http://archive.cloudera.com/cdh4/one-click-install/precise/amd64/cdh4-repository_1.0_all.deb
sudo dpkg -i /vagrant/downloads/cdh4-repository_1.0_all.deb

# Add repository key
echo "Step 0-2"
#curl -s http://archive.cloudera.com/cdh4/ubuntu/precise/amd64/cdh/archive.key | sudo apt-key add -
cat /vagrant/downloads/archive.key | sudo apt-key add -

# Install MRv1/YARN in pseudo-distributed mode
# See http://www.cloudera.com/content/cloudera-content/cloudera-docs/CDH4/4.2.0/CDH4-Quick-Start/cdh4qs_topic_3.html
echo "\n===================="
echo "Installing MRv1 in pseudo-distributed mode"
#echo "Installing YARN in pseudo-distributed mode"
echo "===================="
sudo apt-get update 
sudo apt-get install -y hadoop-0.20-conf-pseudo
#sudo apt-get install -y hadoop-conf-pseudo

# Verify packages
echo "\n===================="
echo "Step 0-3"
echo "===================="
dpkg -L hadoop-0.20-conf-pseudo # MRv1
#dpkg -L hadoop-conf-pseudo

# Start Hadoop

# Step 1: Format the NameNode
echo "\n===================="
echo "Step 1" - Format the NameNode
echo "===================="
sudo -u hdfs hdfs namenode -format

# Step 2: Start HDFS
echo "\n===================="
echo "Step 2" - Start HDFS
echo "===================="
for x in `cd /etc/init.d ; ls hadoop-hdfs-*` ; do sudo service $x start ; done

# Step 3: Create the HDFS /tmp dir
echo "\n===================="
echo "Step 3" - Create HDFS /tmp dirs
echo "===================="
sudo -u hdfs hadoop fs -chmod 777 /
sudo -u hdfs hadoop fs -mkdir /tmp 
sudo -u hdfs hadoop fs -chmod -R 1777 /tmp

# Step 4: Create the MapReduce system directories
echo "\n===================="
echo "Step 4" - Create staging and log dirs
echo "===================="

# MRv1
sudo -u hdfs hadoop fs -mkdir -p /var/lib/hadoop-hdfs/cache/mapred/mapred/staging
sudo -u hdfs hadoop fs -chmod 1777 /var/lib/hadoop-hdfs/cache/mapred/mapred/staging
sudo -u hdfs hadoop fs -chown -R mapred /var/lib/hadoop-hdfs/cache/mapred

# YARN
#sudo -u hdfs hadoop fs -mkdir /tmp/hadoop-yarn/staging
#sudo -u hdfs hadoop fs -chmod -R 1777 /tmp/hadoop-yarn/staging
#sudo -u hdfs hadoop fs -mkdir /tmp/hadoop-yarn/staging/history/done_intermediate
#sudo -u hdfs hadoop fs -chmod -R 1777 /tmp/hadoop-yarn/staging/history/done_intermediate
#sudo -u hdfs hadoop fs -chown -R mapred:mapred /tmp/hadoop-yarn/staging
#sudo -u hdfs hadoop fs -mkdir /var/log/hadoop-yarn
#sudo -u hdfs hadoop fs -chown yarn:mapred /var/log/hadoop-yarn


# Step 5: Verify the HDFS File Structure
echo "\n===================="
echo "Step 5" - Verify the HDFS File Structure
echo "===================="
sudo -u hdfs hadoop fs -ls -R /

# Step 6: Start MapReduce
echo "\n===================="
echo "Step 6" - Start MR/YARN
echo "===================="
# MRv1
for x in `cd /etc/init.d ; ls hadoop-0.20-mapreduce-*` ; do sudo service $x start ; done # MRv1

# YARN
#sudo service hadoop-yarn-resourcemanager start
#sudo service hadoop-yarn-nodemanager start
#sudo service hadoop-mapreduce-historyserver start

# Step 7: Create User Directories
echo "\n===================="
echo "Step 7" - Create user directories
echo "===================="
sudo -u hdfs hadoop fs -mkdir /user/vagrant
sudo -u hdfs hadoop fs -chown vagrant /user/vagrant

echo "\n===================="
echo "Step 8 - Starting Zookeeper"
echo "===================="
#sudo chown -R vagrant:vagrant /usr/lib/zookeeper
#sudo chown -R vagrant:vagrant /var/lib/zookeeper
sudo /usr/lib/zookeeper/bin/zkServer.sh start

echo "\n########################"
echo "Installing Accumulo 1.5.0"
echo "########################\n"
#curl -O -L http://mirrors.gigenet.com/apache/accumulo/$ACCUMULO_VERSION/accumulo-$ACCUMULO_VERSION-bin.deb
#sudo dpkg -i accumulo-$ACCUMULO_VERSION-bin.deb
tar xzf /vagrant/downloads/accumulo-1.5.0-bin.tar.gz -C /home/vagrant

echo "\n########################"
echo "Configuring Accumulo 1.5.0"
echo "########################\n"
sudo mkdir /accumulo
sudo chown -R vagrant:vagrant /accumulo
cp /home/vagrant/accumulo-$ACCUMULO_VERSION/conf/examples/1GB/standalone/* /home/vagrant/accumulo-$ACCUMULO_VERSION/conf/
cat > /home/vagrant/accumulo-$ACCUMULO_VERSION/conf/masters <<EOF
accumulo-dev-box
EOF

cat > /home/vagrant/accumulo-$ACCUMULO_VERSION/conf/slaves <<EOF
accumulo-dev-box
EOF

sed -i 's/>secret</>password</' /home/vagrant/accumulo-$ACCUMULO_VERSION/conf/accumulo-site.xml
sed -i 's/>DEFAULT</>password</' /home/vagrant/accumulo-$ACCUMULO_VERSION/conf/accumulo-site.xml
sed -i 's/HADOOP_PREFIX/HADOOP_HOME/' /home/vagrant/accumulo-$ACCUMULO_VERSION/conf/accumulo-site.xml
sed -i 's/HADOOP_CONF_DIR/HADOOP_HOME\/conf,\n$HADOOP_HDFS_HOME\/[^.].*.jar,\n$HADOOP_HDFS_HOME\/lib\/[^.].*.jar/' /home/vagrant/accumulo-$ACCUMULO_VERSION/conf/accumulo-site.xml

/home/vagrant/accumulo-$ACCUMULO_VERSION/bin/accumulo init --clear-instance-name <<EOF
accumulo
password
password
EOF

echo "Deploying the Amino Accumulo iterator"
cp /vagrant/Amino/amino-accumulo-iterators* /home/vagrant/accumulo-$ACCUMULO_VERSION/lib/ext/

echo "Starting Accumulo..."
/home/vagrant/accumulo-$ACCUMULO_VERSION/bin/start-all.sh

echo "Adding authorizations"
/home/vagrant/accumulo-$ACCUMULO_VERSION/bin/accumulo shell -u root -p password -e "setauths -s U"

echo "Creating the HDFS structures for the number example"
hadoop fs -mkdir /amino/numbers/config
hadoop fs -mkdir /amino/numbers/in
hadoop fs -mkdir /amino/numbers/out
hadoop fs -mkdir /amino/numbers/working/files
hadoop fs -mkdir /amino/numbers/working/failures
hadoop fs -copyFromLocal /vagrant/Amino/NumberLoader.xml /amino/numbers/config
hadoop fs -copyFromLocal /vagrant/Amino/AminoDefaults.xml /amino/numbers/config
hadoop fs -copyFromLocal /vagrant/Amino/numbers-* /amino/numbers/in

echo 'Done!'
