# redhat

This repository contains sourcecodes that I think that might be interesting to share with you.

vagrant_ns
contains a Vagrant file that sets up the following:
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
