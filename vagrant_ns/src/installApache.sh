#!/usr/bin/env bash

if [ -z "$1" ]
then
   clear
   echo "please provide environment as parameter, eg: tst1,tst2,acc1,acc2,acc3,acc4,prd1,prd2,prd3,prd4"
   exit 1
else
   if [ ! -d env/$1 ]
   then
      echo "env $1 does not exist....."
      exit 1
   else
      echo "copying required files into place"
      # APACHE
      cp -f env/$1/apache/* apache/
      echo "cleaning up all instances"
      for anInstance in $(ls ns/jboss/instances/ | grep instance)
      do
        echo "cleaning up ns/jboss/instances/$anInstance"
        rm -rf ns/jboss/instances/$anInstance
      done
      # PROPERTIES
      for anInstance in $(ls env/$1/ns/jboss/instances/)
      do
         echo "now copying env/$1/ns/jboss/instances/$anInstance into ns/jboss/instances/"
         cp -R env/$1/ns/jboss/instances/$anInstance ns/jboss/instances/
      done
      # ETC.INIT
      rm -f /etc/init.d/jboss_*
      cp env/$1/ns/init/* /etc/init.d
      chmod 750 /etc/init.d/jboss_*
      chown jboss. /etc/init.d/jboss_*
   fi
fi

echo "install NS Apache script called..."
yum -y install httpd
cat /etc/httpd/conf/httpd.conf | sed -e ' s/LoadModule\ proxy_balancer_module\ modules\/mod_proxy_balancer.so/#LoadModule\ proxy_balancer_module\ modules\/mod_proxy_balancer.s/ ' > /tmp/httpd.conf
cp -f /tmp/httpd.conf /etc/httpd/conf/httpd.conf
/etc/init.d/iptables stop

echo "loadbalancing stuff"
cp /apps/install/src/apache/jboss-lb.conf /etc/httpd/conf.d/
cp /apps/install/src/apache/mod_cluster/*.so /etc/httpd/modules/

cat /apps/install/src/apache/hosts >> /etc/hosts

echo "starting httpd"
apachectl start
