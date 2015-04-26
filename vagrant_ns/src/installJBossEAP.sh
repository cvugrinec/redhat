#!/usr/bin/env bash

instances="cm-tegel-instance1 co-tegel-instance1 mc-tegel-instance1 dm-tegel-instance1 tm-tegel-instance1 sm-tegel-instance1"

echo "install NS JBoss EAP script called..."
#yum makecache fast
#yum upgrade

echo "creating startup stuff"
cp /vagrant/src/ns/init/* /etc/init.d/
chown root /etc/init.d/jboss_*
chmod 755 /etc/init.d/jboss_*
chkconfig --add jboss_all

echo "user mgmt stuff"
if [[ $(getent group ovcp) == "" ]]
then
  groupadd ovcp
fi
if [[ $(getent passwd jboss) == "" ]]
then
   adduser jboss -g ovcp
fi
cp /vagrant/src/.bashrc /home/jboss/

echo "quartz related stuff copy"
mkdir -p /opt/ns/data/quartzdesk-agent
chown -R jboss:ovcp /opt/ns/data
cp -R /vagrant/src/quartz/quartzdesk /opt/ns/data/
cp -R /vagrant/src/quartz/quartzdesk-agent /opt/ns/data/

echo "extracting jboss stuff"
#  IMPORT COPY ACTION
cp -R /vagrant/src/ns /opt
chown -R jboss:ovcp /opt/ns

echo "creating symbolic links"
cd /opt
ln -s /opt/ns/java/jdk1.7.0_75/ java
ln -s /opt/ns/jboss/jboss-eap-6.3/ jboss
ln -s /opt/ns/jboss/instances/ jboss-servers

# weird symbolic link stuff that needed cleaning up ...vagrant stuff???
cd /opt/java
rm -f jdk1.7.0_75
cd /opt/jboss-servers
rm -f instances
cd /opt/jboss
rm -f jboss-eap-6.3

echo "creating logging directories"
for instance in $instances
do
   echo "creating Logging directory: /var/log/jboss-servers/$instance"
   mkdir -p /var/log/jboss-servers/$instance

   # Extracting base stuff
   cd /opt/jboss-servers/$instance
   tar -xvf /vagrant/src/ns/jboss/instances/base/minimal-standalone.tar

   echo "copying start and stop scripts, and usermgmt"
   cp /vagrant/src/ns/jboss/instances/base/start.sh /opt/jboss-servers/$instance/
   if [[ -f /vagrant/src/ns/jboss/instances/$instance/start.sh ]]
   then
      echo "found start.sh file...so overwriting default start script"
      cp /vagrant/src/ns/jboss/instances/$instance/start.sh /opt/jboss-servers/$instance/
   fi
   cp /vagrant/src/ns/jboss/instances/base/stop.sh /opt/jboss-servers/$instance/
   chown jboss:ovcp /opt/jboss-servers/$instance/*.sh
   chmod 750 /opt/jboss-servers/$instance/*.sh
   cp /vagrant/src/ns/jboss/jboss-eap-6.3/standalone/configuration/mgmt* /opt/jboss-servers/$instance/configuration/
done
chown -R jboss:ovcp /var/log/jboss-servers/

# make sure starting all over
/etc/init.d/jboss_all stop
for instance in $instances
do
   rm -f /opt/jboss-servers/$instance/$instance.pid
done

for instance in $instances
do
   echo "starting instance $instance"
   /etc/init.d/jboss_$instance start
   sleep 3
   echo "creating symbolic links to logfiles"
   ln -s /var/log/jboss-servers/$instance/ /opt/jboss-servers/$instance/logs
   offset=`cat /opt/jboss-servers/$instance/properties | grep offset | sed ' s/offset=// '`
   hostname2=`cat /opt/jboss-servers/$instance/properties | grep hostname | sed ' s/hostname=// '`
   echo "Config JBoss instance $instance with port offset $offset"
   /vagrant/src/configEAP.sh $offset $hostname2
   echo "stopping instance $instance"
   /etc/init.d/jboss_$instance stop
done
