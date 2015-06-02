#############################################################################
#
#  name: checkEap.sh
#  description: wrapper for the eap-healthcheck
#  contact: cvugrinec@redhat.com
#
#############################################################################
#!/bin/bash

instancename=$1

script=$(readlink -f "$0")
scriptDir=$(dirname "$script")
cd $scriptDir

curDir=`pwd`
instanceDir=/opt/jboss-servers/$instancename
hostname=`hostname -f`
offset=`cat $instanceDir/properties | grep offset | sed ' s/offset=// '`
ctrlPort=$(($offset + 9999))
counter=0


export CLASSPATH=$curDir/lib/jboss-cli-client.jar:$curDir/lib/jython.jar:$curDir/lib/rt.jar
java -cp $CLASSPATH org.python.util.jython jython/clearCache.jy $hostname $ctrlPort 
