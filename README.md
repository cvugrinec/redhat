# redhat

This repository contains sourcecodes that I think that might be interesting to share with you.

dv-googleanalytics-demo
========================
contains my 1st JBoss Data Virtualization project, which combines 2 data(base)sources, 1 excel file and the (json) results of 2 google analytics rest services


vagrant_ns
==========
contains a Vagrant file which calls scripts that sets up the following:
 - Centos 6.6 with all the required users
 - JBoss eap 6.3.0 installation with java 1.7
 - Sets up 6 different instances with port offset by 100
 - Configures certain settings per instance with cli scripts
 - One the instances is configured to run with quartz, for quartz the following is configured
  - an additional application security realm/
  - additional user with the add-user.sh script
  - additional startup parameters
  - additional system variables
  - additional datasource
 - configures instances to use the mod_cluster
 - Installs apache 2.2.4 with the required mod_cluster modules
 - Contains some scripts that could be interesting for starting/ stopping and status of jboss eap

This stuff can be copied in /vagrant  and just be runned with the install.sh script as root user....
however this repo does not contain the binaries...missing binaries should be in the following directories:
- src/ns/java/jdk1.7.0_75/
- src/ns/jboss/jboss-eap-6.3/
- src/ns/modules/default/   (this is just the modules directory which comes with the default installation)
- src/ns/modules/mc/  (this is just the modules directory which comes with the default installation with additional modules for a specific instance)

I have chosen to seperate the modules from the standard installation by adding the -mp parameter, which directs to the specified modules directory
