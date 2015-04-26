export JAVA_HOME=/opt/java
export PATH=$PATH:$JAVA_HOME/bin

cd /opt/jboss-servers/mc-tegel-instance1
offset=`cat properties | grep offset | sed ' s/offset=// '`
ctrlPort=$(($offset + 9999))
hostname=`hostname -f`

echo "starting mc tegel"
/etc/init.d/jboss_mc-tegel-instance1 stop
/etc/init.d/jboss_mc-tegel-instance1 start
sleep 10

mkdir -p /opt/jboss/modules/com
chown -R jboss. /opt/jboss/modules/com

# config JDBC datasource
sudo -u jboss -E /opt/jboss/bin/jboss-cli.sh --connect --controller=$hostname:$ctrlPort < /vagrant/src/mc-tegel/mc-jdbc.cli

touch /opt/jboss-servers/mc-tegel-instance1/configuration/quartzdesk-users.properties
/opt/jboss/bin/add-user.sh -r QuartzDeskRealm –a -up /opt/jboss-servers/mc-tegel-instance1/configuration/quartzdesk-users.properties -p Welcome01! -u quartzdesk
cp /vagrant/src/quartz/quartzdesk-roles.properties /opt/jboss-servers/mc-tegel-instance1/configuration/

# MC Tegel needs quartzDesk Stuff
echo "Config MC Tegel....."
sudo -u jboss -E /opt/jboss/bin/jboss-cli.sh --connect --controller=$hostname:$ctrlPort < /vagrant/src/mc-tegel/mc-tegel.cli

/etc/init.d/jboss_mc-tegel-instance1 stop

mv -f /opt/jboss-servers/mc-tegel-instance1/start.sh.backup /opt/jboss-servers/mc-tegel-instance1/start.sh
