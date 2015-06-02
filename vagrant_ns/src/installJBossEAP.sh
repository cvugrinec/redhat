#!/bin/bash

if [ -z "$1" ]
then
   clear
   echo "please provide environment as parameter, eg: tst1,tst2,acc1,acc2,acc3,acc4,prd1,prd2,prd3,prd4"  
   exit 1
else
   if [ ! -d env/$1 ] 
   then
      echo "env $1 does not exist....."
      exit 1
   else
      echo "copying required files into place"
      # APACHE
      cp -f env/$1/apache/* apache/
      echo "cleaning up all instances"
      for anInstance in $(ls ns/jboss/instances/ | grep instance)
      do
        echo "cleaning up ns/jboss/instances/$anInstance"
	rm -rf ns/jboss/instances/$anInstance
      done
      # PROPERTIES
      for anInstance in $(ls env/$1/ns/jboss/instances/)
      do
         echo "now copying env/$1/ns/jboss/instances/$anInstance into ns/jboss/instances/"
         cp -R env/$1/ns/jboss/instances/$anInstance ns/jboss/instances/
      done
      # ETC.INIT
      rm -f /etc/init.d/jboss_*
      cp env/$1/ns/init/* /etc/init.d
      chmod 750 /etc/init.d/jboss_*
      chown jboss. /etc/init.d/jboss_*
   fi
fi

instances=$(ls env/$1/ns/jboss/instances/)


chkconfig --add jboss_all
echo "config of jboss instances"

echo "install NS JBoss EAP script called..."
#yum makecache fast
#yum upgrade

echo "quartz related stuff copy"
mkdir -p /apps/ns/data/quartzdesk-agent
chown -R jboss. /apps/ns/data
cp -R /apps/install/src/quartz/quartzdesk /apps/ns/data/
cp -R /apps/install/src/quartz/quartzdesk-agent /apps/ns/data/

echo "user mgmt stuff"
if [[ $(getent group nfast) == "" ]]
then
   groupadd nfast
fi
if [[ $(getent group ovcp) == "" ]]
then
   groupadd ovcp
fi
if [[ $(getent passwd jboss) == "" ]]
then
   adduser jboss -g ovcp -g nfast
fi
cp /apps/install/src/.bashrc /home/jboss/

echo "extracting jboss stuff"
#  IMPORT COPY ACTION
cp -R /apps/install/src/ns /apps
chown -R jboss:ovcp /apps/ns
ln -s /apps/ns/modules/ /opt/ns/modules

echo "creating symbolic links"
cd /opt
ln -s /apps/ns/java/jdk1.7.0_75/ java
ln -s /usr/lib/jvm/java-1.7.0-openjdk-1.7.0.65.x86_64/jre/ java_sm
rm -f /opt/java/jdk1.7.0_75
ln -s /apps/ns/jboss/jboss-eap-6.3/ jboss
rm -f /opt/jboss/jboss-eap-6.3
ln -s /apps/ns/jboss/instances/ jboss-servers
rm -f /opt/jboss-servers/instances
ln -s /apps/ns/ ns

for instance in $instances
do
   echo "creating Logging directory: /var/log/jboss-servers/$instance"
   mkdir -p /var/log/jboss-servers/$instance

   # Extracting base stuff
   cd /opt/jboss-servers/$instance
   tar -xvf /apps/install/src/ns/jboss/instances/base/minimal-standalone.tar

   echo "copying start and stop scripts, and usermgmt"
   cp /apps/install/src/ns/jboss/instances/base/start.sh /opt/jboss-servers/$instance/
   if [[ -f /apps/install/src/ns/jboss/instances/$instance/start.sh ]]
   then
      echo "found start.sh file...so overwriting default start script"
      cp /apps/install/src/ns/jboss/instances/$instance/start.sh /opt/jboss-servers/$instance/
   fi
   cp /apps/install/src/ns/jboss/instances/base/stop.sh /opt/jboss-servers/$instance/
   chown jboss. /opt/jboss-servers/$instance/*.sh
   chmod 750 /opt/jboss-servers/$instance/*.sh
done
chown -R jboss. /var/log/jboss-servers/

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
   ln -s /var/log/jboss-servers/$instance/ /opt/jboss-servers/$instance/log
   offset=`cat /opt/jboss-servers/$instance/properties | grep offset | sed ' s/offset=// '`
   hostname2=`cat /opt/jboss-servers/$instance/properties | grep hostname | sed ' s/hostname=// '`
   echo "Config JBoss instance $instance with port offset $offset"


   /apps/install/src/configEAP.sh $offset $hostname2 $1
   echo "stopping instance $instance"
   /etc/init.d/jboss_$instance stop
done

echo "User mgmt creation"
/opt/jboss/bin/add-user.sh -u jbossAdmin -p 'jboss4dm!n'

for instance in $instances
do
   cp /opt/jboss/standalone/configuration/mgmt-*  /opt/jboss-servers/$instance/configuration/
done

# check and cleanup
/etc/init.d/jboss_all start
/opt/jboss-servers/base/status.sh
 
rm -f /opt/java_sm/jr
rm -f /opt/ns/modules/modules

