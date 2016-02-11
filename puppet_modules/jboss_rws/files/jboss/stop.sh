script=$(readlink -f "$0")
instanceDir=$(dirname "$script")
instanceName=`echo $instanceDir | sed -e 's/\/.*\///'`
hostName=`hostname -f`
offset=`cat $instanceDir/properties | grep offset | sed ' s/offset=// '`
ctrlPort=$(($offset + 9999))
force=$1

export JAVA_HOME=/opt/java
export PATH=$PATH:$JAVA_HOME/bin

cleanup(){
   echo "Stop of instance $instanceName OK, cleaning up pid file..."
   rm -f  $instanceDir/$instanceName.pid
}


if [[ $force == "-f" ]]
then
   kill -9 $(ps -ef | grep -i $instanceName | grep -v grep | awk ' { print $2} ') 2>/dev/null
else
   /opt/jboss/bin/jboss-cli.sh --connect --controller=$hostName:$ctrlPort :shutdown 2>/dev/null
   resultCode=`echo $?`
   if [ $resultCode != 0 ]
   then
     pidz=`ps -ef | grep -i $instanceName | grep -v grep | awk ' { print $2} '`
     if [[ $pidz != "" ]]
     then
       kill -9 $(ps -ef | grep -i $instanceName | grep -v grep | awk ' { print $2} ') 2>/dev/null
     fi
   fi
fi

cleanup
