for instance in $(ls /opt/jboss-servers/ | grep -i instance)
do
  var1=`echo $instance`
  var2=`/etc/init.d/jboss_$instance status | grep "result"`
  var3=`cat /opt/jboss-servers/$instance/properties | grep offset`
  var4=`ps -ef | grep -i java | grep $instance | awk ' { print "pid:  "$3" "$19" "$20" "$21 } '`
  echo $var1 $var2 $var3 $var4
done
