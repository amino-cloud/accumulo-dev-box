#!/bin/bash
source /vagrant/scripts/common.sh

function setupJdk {
	echo "setting up jdk"
	if fileExists $RESOURCE_JDK; then
		echo "install oracle jdk"
		tar -xzf $RESOURCE_JDK -C /usr/local
		ln -s /usr/local/jdk1.7.0_51 /usr/local/java
	else
		echo "install open jdk"
		yum install -y java-1.7.0-openjdk.x86_64
		ln -s /usr/lib/jvm/jre /usr/local/java
	fi
	
	echo export JAVA_HOME=/usr/local/java >> /etc/profile.d/java.sh
	echo export PATH=\${JAVA_HOME}/bin:\${PATH} >> /etc/profile.d/java.sh
}

setupJdk