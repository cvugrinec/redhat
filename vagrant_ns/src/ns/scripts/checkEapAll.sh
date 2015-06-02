curDir=`pwd`
for instance in $(ls /opt/jboss-servers/ | grep -i instance)
do
  $curDir/checkEap.sh $instance
done
