script=$(readlink -f "$0")
instanceDir=$(dirname "$script")
instanceName=`echo $instanceDir | sed -e 's/\/.*\///'`
hostname=`hostname -f`
offset=`cat $instanceDir/properties | grep offset | sed ' s/offset=// '`
ctrlPort=$(($offset + 9999))
counter=0

export JBOSS_MODULEPATH=/opt/ns/modules/default
export JAVA_HOME=/opt/java
export PATH=$PATH:$JAVA_HOME/bin
export JAVA_OPTS="$JAVA_OPTS -Xms512m -Xmx512m -XX:MaxPermSize=128m -Dcom.ibm.msg.client.commonservices.log.outputName=/var/log/jboss-servers/$instanceName/wmq.log -Dcom.ibm.msg.client.commonservices.log.count=5 -Dcom.ibm.msg.client.commonservices.log.maxBytes=1000000"

checkStatus(){
    /opt/jboss/bin/jboss-cli.sh --connect --controller=$hostname:$ctrlPort ":read-attribute(name=server-state)" 2>/dev/null
    resultCode=`echo $?`
    counter=$(($counter+ 1))
    if [[ $resultCode != 0 ]]
    then
       echo "could not connect, retrying 1 more time"
    else
       echo "succesfully started"
       exit 0
    fi
    if [[ $counter>=5 ]]
    then
       echo "could not get status...within 5 time, exiting with errorcode 1"
       exit 1
    fi
    sleep 3
}

if [[ -f $instanceDir/$instanceName.pid ]]
then
   echo "instance already started...."
   exit 1
fi
if [[ `whoami` == "jboss" ]]
then
      nohup /opt/jboss/bin/standalone.sh -Djboss.server.base.dir=$instanceDir -Djboss.socket.binding.port-offset=$offset -Djboss.server.log.dir=/var/log/jboss-servers/$instanceName/  --server-config=standalone-full-ha.xml > /dev/null 2>&1&
   if [[ $1 == "-d" ]]
   then
      tail -f /var/log/jboss-servers/$instanceName/server.log
   else
      echo $! > $instanceDir/$instanceName.pid
   fi
else
   echo "please start as user jboss"
   exit 1
fi

pid=`cat $instanceDir/$instanceName.pid`
resultCode=`echo $?`
if [[ $pid == "" ]]
then
   echo "service not started"
   exit 1
fi
if [[ $resultCode != 0 ]]
then
   echo "Error starting up instance $instanceName errorCode: $resultCode"
   exit 1
else
   echo "instance $instanceName started succesfully"
   ps -ef | grep $pid
   while true
   do
      checkStatus
   done
fi
