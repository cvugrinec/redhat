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

echo "hello world" >output/$instancename.json

export CLASSPATH=$curDir/lib/jboss-cli-client.jar:$curDir/lib/jython.jar:$curDir/lib/rt.jar
java -cp $CLASSPATH org.python.util.jython jython/checkInstance.jy $hostname $ctrlPort >output/$instancename.json 
exitCode=$?
if [[ $exitCode != 0 ]]
then
   echo "Exit code: "$exitCode
   exit $exitCode
fi

# Check logfiles for this eap instance for exceptions
logDirectory="/var/log/jboss-servers/$instancename"
if [[ -d $logDirectory ]]
then
   found="false"
   echo "\"logfiles\" : {"  >>output/$instancename.json.tmp
   files=$(find /var/log/jboss-servers/$instancename -name \*.log | grep -v 201 )
   for file in $files
   do
      exceptionsFound=`tail -250 $file | grep -i exception`
      if [[ $exceptionsFound != "" ]]
      then
         found="true"
         counter=$((counter+1))
         exceptionsFound2=`echo $exceptionsFound | sed -e 's/\"//g' -e 's/\\\//g'`
         echo "   \"$file\" : {" >>output/$instancename.json.tmp
         echo "      \"exceptions\" : \"$exceptionsFound2\""  >>output/$instancename.json.tmp
         echo "    },"  >>output/$instancename.json.tmp
      fi
   done
   if [[ $found == "true" ]]
   then 
      # remove last line (replace with }) without ,
      sed -i '$ d' output/$instancename.json.tmp
      echo "      }"  >>output/$instancename.json.tmp
      echo "   }"  >>output/$instancename.json.tmp
      cat output/$instancename.json.tmp >>  output/$instancename.json
      rm  output/$instancename.json.tmp
      echo "}"  >>output/$instancename.json
   else
       sed -i '$ d' output/$instancename.json
       echo "}" >> output/$instancename.json
   fi
else
   echo "directory: "$logDirectory" not found"  >>output/$instancename.json
   exit 1
fi
