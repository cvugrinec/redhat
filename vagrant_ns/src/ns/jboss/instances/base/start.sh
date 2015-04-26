script=$(readlink -f "$0")
instanceDir=$(dirname "$script")
instanceName=`echo $instanceDir | sed -e 's/\/.*\///'`
offset=`cat $instanceDir/properties | grep offset | sed ' s/offset=// '`

export JBOSS_MODULEPATH=/opt/ns/modules/default
export JAVA_HOME=/opt/java
export PATH=$PATH:$JAVA_HOME/bin
export JAVA_OPTS="$JAVA_OPTS -Xms512m -Xmx512m -XX:MaxPermSize=128m"

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
fi
