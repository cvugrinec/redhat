export JAVA_HOME=/opt/java
export PATH=$PATH:$JAVA_HOME/bin

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
echo "/subsystem=modcluster/mod-cluster-config=configuration:write-attribute(name=balancer,value=$hostnameParam)" >> /tmp/$hostnameParam.cli
echo "/subsystem=modcluster/mod-cluster-config=configuration:write-attribute(name=proxy-list,value=$hostnameParam:80)" >> /tmp/$hostnameParam.cli
echo "/subsystem=web/virtual-server=default-host:write-attribute(name=alias,value=[$hostnameParam])" >> /tmp/$hostnameParam.cli
echo "/subsystem=messaging/hornetq-server=default:write-attribute(name=cluster-password,value=$hostnameParam)" >> /tmp/$hostnameParam.cli
echo "/subsystem=messaging/hornetq-server=default:write-attribute(name=cluster-user,value=$hostnameParam)" >> /tmp/$hostnameParam.cli
# Reloading stuff
echo ":reload" >> /tmp/$hostnameParam.cli
sleep 1

echo "finished creating command File, now executing it...on $hostname:$ctrlPort"
sudo -u jboss -E /opt/jboss/bin/jboss-cli.sh --connect --controller=$hostname:$ctrlPort < /tmp/$hostnameParam.cli
echo "sleep 1..."
sleep 1
