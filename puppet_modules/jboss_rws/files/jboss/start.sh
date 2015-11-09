script=$(readlink -f "$0")
instanceDir=$(dirname "$script")
instanceName=`echo $instanceDir | sed -e 's/\/.*\///'`
hostname=`hostname -f`
offset=`cat $instanceDir/properties | grep offset | sed ' s/offset=// '`
ctrlPort=$(($offset + 9999))
counter=0

export JBOSS_MODULEPATH=/opt/jboss/modules/
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.65-2.b17.el7_1.x86_64/jre
export PATH=$PATH:$JAVA_HOME/bin
export JAVA_OPTS="$JAVA_OPTS -Xms1024m -Xmx1024m -XX:MaxPermSize=256m"


if [[ -f $instanceDir/$instanceName.pid ]]
then
   echo "instance already started...."
   exit 1
fi
if [[ `whoami` == "jboss" ]]
then
      nohup /opt/jboss/bin/standalone.sh -Djboss.server.base.dir=$instanceDir -Djboss.socket.binding.port-offset=$offset -Djboss.server.log.dir=/var/log/jboss-instances/$instanceName/  --server-config=standalone.xml --properties=$instanceDir/properties > /dev/null 2>&1&
   if [[ $1 == "-d" ]]
   then
      tail -f /var/log/jboss-instances/$instanceName/server.log
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
fi
