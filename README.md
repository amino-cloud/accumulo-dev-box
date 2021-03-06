# Introduction

Spins up a development VM for running Amino against.  There are currently multiple VMs to choose from:

- CDH3u3 - Cloudera build of Hadoop and Zookeeper (cdh3u3) with Accumulo 1.4.4
- CDH4u5 - Cloudera build of Hadoop and Zookeeper (cdh4u5) with YARN/mr2 and Accumulo 1.5.0

# Getting Started

1. [Download and install VirtualBox](https://www.virtualbox.org/wiki/Downloads)
2. [Download and install Vagrant](http://www.vagrantup.com/downloads.html)
3. Run ```vagrant box add precise64 http://files.vagrantup.com/precise64.box```
4. Clone one of the sub projects
5. Run ```vagrant up``` from within the project directory. You'll need at least 2Gb free.
6. Run ```vagrant ssh``` from within the project directory to get into your VM, or open up the VirtualBox
   Manager app to tweak settings, forward ports, etc.
7. The app can now be accessed at port 10.211.55.100. To make it accessible at "accumulo-dev-box", add
   the following to the end of your /etc/hosts file: ```10.211.55.100 accumulo-dev-box```
8. Run ```/vagrant/Amino/rubJobs.sh``` once you have SSH'd in.  This will run Amino 2.1.0 against the numbers dataset and populate Accumulo
