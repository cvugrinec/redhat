export JAVA_HOME=/opt/java
export PATH=$PATH:$JAVA_HOME/bin

if [ -z "$1" ]
then
   clear
   echo "please provide environment as parameter, eg: tst1,tst2,acc1,acc2,acc3,acc4,prd1,prd2,prd3,prd4"
   exit 1
else
   instance=$(ls env/$1/ns/jboss/instances/ | grep -i mc-tegel-instance)
fi

echo "configuring instance $instance"

cd /opt/jboss-servers/$instance
offset=`cat properties | grep offset | sed ' s/offset=// '`
ctrlPort=$(($offset + 9999))
hostname=`hostname -f`

echo "starting mc tegel"
/etc/init.d/jboss_$instance stop
/etc/init.d/jboss_$instance start
sleep 10

mkdir -p /opt/jboss/modules/com
chown -R jboss. /opt/jboss/modules/com

# config JDBC datasource
sudo -u jboss -E /opt/jboss/bin/jboss-cli.sh --connect --controller=$hostname:$ctrlPort < /apps/install/src/mc-tegel/mc-jdbc.cli

touch /opt/jboss-servers/$instance/configuration/quartzdesk-users.properties
/opt/jboss/bin/add-user.sh -r QuartzDeskRealm –a -up /opt/jboss-servers/$instance/configuration/quartzdesk-users.properties -p Welcome01! -u quartzdesk
cp /apps/install/src/quartz/quartzdesk-roles.properties /opt/jboss-servers/$instance/configuration/

# MC Tegel needs quartzDesk Stuff
echo "Config MC Tegel....."
sudo -u jboss -E /opt/jboss/bin/jboss-cli.sh --connect --controller=$hostname:$ctrlPort < /apps/install/src/mc-tegel/mc-tegel.cli

/etc/init.d/jboss_$instance stop

mv -f /opt/jboss-servers/$instance/start.sh.backup /opt/jboss-servers/$instance/start.sh
chmod 755 /opt/jboss-servers/$instance/start.sh
