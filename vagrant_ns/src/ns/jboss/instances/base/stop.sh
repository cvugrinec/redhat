script=$(readlink -f "$0")
instanceDir=$(dirname "$script")
instanceName=`echo $instanceDir | sed -e 's/\/.*\///'`
hostName=`hostname -f`
#hostName="192.168.33.10"
offset=`cat $instanceDir/properties | grep offset | sed ' s/offset=// '`
ctrlPort=$(($offset + 9999))

export JAVA_HOME=/opt/java
export PATH=$PATH:$JAVA_HOME/bin

cleanup(){
   echo "Stop of instance $instanceName OK, cleaning up pid file..."
   rm -f  $instanceDir/$instanceName.pid
}

/opt/jboss/bin/jboss-cli.sh --connect --controller=$hostName:$ctrlPort :shutdown 2>/dev/null
resultCode=`echo $?`
if [ $resultCode != 0 ]
then
    pid=`cat $instanceDir/$instanceName.pid`
    echo "Stop of instance $instanceName NOT OK, pid file...trying to kill pid $pid"
    kill $pid
    cleanup
    for pid in `ps -ef | grep -i $instanceName | grep -v grep | awk ' { print $2} '`
    do
       kill -9 $pid 2>/dev/null
    done
fi
cleanup
