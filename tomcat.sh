#!/bin/bash
#export JAVA_HOME=/usr/lib/jvm/java-7-oracle/
export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/

echo "Installing Tomcat7 and admin console"
sudo apt-get install -y tomcat7 tomcat7-admin

echo "Adding the user accounts to Tomcat"
sudo sed -i "s/<\/tomcat-users>//" /etc/tomcat7/tomcat-users.xml
sudo cat >> /etc/tomcat7/tomcat-users.xml <<EOF
<role rolename="testrole"/>
<user username="testuser1" password="password" roles="testrole"/>
<user username="testuser2" password="password" roles="testrole"/>
<user username="testuser3" password="password" roles="testrole"/>
<user username="testuser4" password="password" roles="testrole"/>
<user username="testuser5" password="password" roles="testrole"/>
<user username="admin" password="password" roles="admin-gui,manager-gui"/>
</tomcat-users>
EOF

sudo chgrp -R tomcat7 /etc/tomcat7
sudo chmod -R g+w /etc/tomcat7 

