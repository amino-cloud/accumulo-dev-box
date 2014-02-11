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
export ZOOKEEPER_HOME=/usr/lib/zookeeper
export ACCUMULO_HOME=/usr/lib/accumulo
EOF
export JAVA_HOME=$JDK_LOC
export HADOOP_HOME=/usr/lib/hadoop
export ZOOKEEPER_HOME=/usr/lib/zookeeper
export ACCUMULO_HOME=/usr/lib/accumulo

echo "\n===================="
echo "Fetching CDH4"
echo "===================="
wget http://archive.cloudera.com/cdh4/one-click-install/precise/amd64/cdh4-repository_1.0_all.deb
sudo dpkg -i cdh4-repository_1.0_all.deb

# Add repository key
echo "Step 0-2"
curl -s http://archive.cloudera.com/cdh4/ubuntu/precise/amd64/cdh/archive.key | sudo apt-key add -

# Install MRv1 pseudo-distributed mode
echo "\n===================="
echo "Installing MRv1 in pseudo-distributed mode"
echo "===================="
sudo apt-get update 
sudo apt-get install -y hadoop-0.20-conf-pseudo

# Verify packages
echo "\n===================="
echo "Step 0-3"
echo "===================="
dpkg -L hadoop-0.20-conf-pseudo

# Start Hadoop

# Step 1: Format the NameNode
echo "\n===================="
echo "Step 1"
echo "===================="
sudo -u hdfs hdfs namenode -format

# Step 2: Start HDFS
echo "\n===================="
echo "Step 2"
echo "===================="
for x in `cd /etc/init.d ; ls hadoop-hdfs-*` ; do sudo service $x start ; done

# Step 3: Create the HDFS /tmp dir
echo "\n===================="
echo "Step 3"
echo "===================="
sudo -u hdfs hadoop fs -mkdir /tmp 
sudo -u hdfs hadoop fs -chmod -R 1777 /tmp

# Step 4: Create the MapReduce system directories
echo "\n===================="
echo "Step 4"
echo "===================="
sudo -u hdfs hadoop fs -mkdir -p /var/lib/hadoop-hdfs/cache/mapred/mapred/staging
sudo -u hdfs hadoop fs -chmod 1777 /var/lib/hadoop-hdfs/cache/mapred/mapred/staging
sudo -u hdfs hadoop fs -chown -R mapred /var/lib/hadoop-hdfs/cache/mapred

# Step 5: Verify the HDFS File Structure
echo "\n===================="
echo "Step 5"
echo "===================="
sudo -u hdfs hadoop fs -ls -R /

# Step 6: Start MapReduce
echo "\n===================="
echo "Step 6"
echo "===================="
for x in `cd /etc/init.d ; ls hadoop-0.20-mapreduce-*` ; do sudo service $x start ; done

# Step 7: Create User Directories
echo "\n===================="
echo "Step 7"
echo "===================="
sudo -u hdfs hadoop fs -mkdir /user/vagrant
sudo -u hdfs hadoop fs -chown vagrant /user/vagrant

echo "\n===================="
echo "Step 8 - Starting Zookeeper"
echo "===================="
sudo chown -R vagrant:vagrant /usr/lib/zookeeper
sudo chown -R vagrant:vagrant /var/lib/zookeeper
/usr/lib/zookeeper/bin/zkServer.sh start

echo "\n########################"
echo "Installing Accumulo 1.5.0"
echo "########################\n"
curl -O -L http://mirrors.gigenet.com/apache/accumulo/$ACCUMULO_VERSION/accumulo-$ACCUMULO_VERSION-bin.deb
sudo dpkg -i accumulo-$ACCUMULO_VERSION-bin.deb
sudo chown -R vagrant:vagrant -R /usr/lib/accumulo

echo "\n########################"
echo "Configuring Accumulo 1.5.0"
echo "########################\n"
sudo chown -R vagrant:vagrant /etc/accumulo
sudo chown -R vagrant:vagrant /usr/lib/accumulo
cp /usr/lib/accumulo/conf/examples/1GB/standalone/* /usr/lib/accumulo/conf/
cat > /usr/lib/accumulo/conf/masters <<EOF
accumulo-dev-box
EOF

cat > /usr/lib/accumulo/conf/slaves <<EOF
accumulo-dev-box
EOF
sed -i 's/>DEFAULT</>password</' /usr/lib/accumulo/conf/accumulo-site.xml
/usr/lib/accumulo/bin/accumulo init --clear-instance-name <<EOF
accumulo
password
password
EOF

echo "Deploying the Amino Accumulo iterator"
cp /vagrant/Amino/amino-accumulo-iterators* /usr/lib/accumulo/lib/ext/

echo "Starting Accumulo..."
/usr/lib/accumulo/bin/start-all.sh

echo "Adding authorizations"
/usr/lib/accumulo/bin/accumulo shell -u root -p password -e "setauths -s U"

echo "Creating the HDFS structures for the number example"
hadoop fs -mkdir /amino/numbers/config
hadoop fs -mkdir /amino/numbers/in
hadoop fs -mkdir /amino/numbers/out
hadoop fs -mkdir /amino/numbers/working
hadoop fs -copyFromLocal /vagrant/Amino/NumberLoader.xml /amino/numbers/config
hadoop fs -copyFromLocal /vagrant/Amino/AminoDefaults.xml /amino/numbers/config
hadoop fs -copyFromLocal /vagrant/Amino/numbers-* /amino/numbers/in

echo 'Done!'
