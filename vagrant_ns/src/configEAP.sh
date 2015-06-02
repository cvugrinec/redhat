export JAVA_HOME=/opt/java
export PATH=$PATH:$JAVA_HOME/bin

env_server=$3
offset=$1
hostnameParam=$2
ctrlPort=$(($offset + 9999))
newHostname=`hostname -f`
hostname="127.0.0.1"
# create cli command file based on params
#  Listen Address
echo "/interface=management:write-attribute(name=inet-address,value=$newHostname)" > /tmp/$hostnameParam.cli
echo "/interface=public:write-attribute(name=inet-address,value=$newHostname)" >> /tmp/$hostnameParam.cli
echo "/subsystem=modcluster/mod-cluster-config=configuration:write-attribute(name=excluded-contexts,value=ROOT)" >> /tmp/$hostnameParam.cli
echo "/subsystem=modcluster/mod-cluster-config=configuration:write-attribute(name=proxy-list,value=$env_server:80)" >> /tmp/$hostnameParam.cli
echo "/subsystem=web/virtual-server=default-host:write-attribute(name=alias,value=[$hostnameParam])" >> /tmp/$hostnameParam.cli
echo "/subsystem=messaging/hornetq-server=default:write-attribute(name=cluster-password,value=$hostnameParam)" >> /tmp/$hostnameParam.cli
echo "/subsystem=messaging/hornetq-server=default:write-attribute(name=cluster-user,value=$hostnameParam)" >> /tmp/$hostnameParam.cli
# Removing the default Hornet Q server
echo "/subsystem=messaging/hornetq-server=default:remove()" >> /tmp/$hostnameParam.cli

# Setting the logging
echo "/subsystem=logging/size-rotating-file-handler=jboss-size-rotating-filehandler:add(file={path=>server.log, relative-to=>jboss.server.log.dir})" >> /tmp/$hostnameParam.cli
echo "/subsystem=logging/size-rotating-file-handler=jboss-size-rotating-filehandler:write-attribute(name=max-backup-index,value=3)" >> /tmp/$hostnameParam.cli
echo "/subsystem=logging/size-rotating-file-handler=jboss-size-rotating-filehandler:write-attribute(name=rotate-size,value=5m)" >> /tmp/$hostnameParam.cli
echo "/subsystem=logging/root-logger=ROOT:remove-handler(name=FILE)" >> /tmp/$hostnameParam.cli
echo "/subsystem=logging/root-logger=ROOT:add-handler(name=jboss-size-rotating-filehandler)" >> /tmp/$hostnameParam.cli

# Reloading stuff
echo ":reload" >> /tmp/$hostnameParam.cli
sleep 1

echo "finished creating command File, now executing it...on $hostname:$ctrlPort"
sudo -u jboss -E /opt/jboss/bin/jboss-cli.sh --connect --controller=$hostname:$ctrlPort < /tmp/$hostnameParam.cli
echo "sleep 1..."
sleep 1
