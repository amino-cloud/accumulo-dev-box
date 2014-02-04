#!/bin/bash
#export JAVA_HOME=/usr/lib/jvm/java-7-oracle/
export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/

echo "Installing Tomcat7 and admin console"
sudo apt-get install -y tomcat7 tomcat7-admin

sudo chgrp -R tomcat7 /etc/tomcat7
sudo chmod -R g+w /etc/tomcat7 

# https://help.ubuntu.com/13.10/serverguide/tomcat.html
#The first one is the manager webapp, which you can access by default at http://yourserver:8080/manager/html. It is primarily used to get server status and restart webapps.

#Access to the manager application is protected by default: you need to define a user with the role "manager-gui" in /etc/tomcat7/tomcat-users.xml before you can access it.

#The second one is the host-manager webapp, which you can access by default at http://yourserver:8080/host-manager/html. It can be used to create virtual hosts dynamically.

#Access to the host-manager application is also protected by default: you need to define a user with the role "admin-gui" in /etc/tomcat7/tomcat-users.xml before you can access it.
