#!/usr/bin/env bash

echo "install NS JBoss EAP script called..."
yum -y install httpd
cat /etc/httpd/conf/httpd.conf | sed -e ' s/LoadModule\ proxy_balancer_module\ modules\/mod_proxy_balancer.so/#LoadModule\ proxy_balancer_module\ modules\/mod_proxy_balancer.s/ ' > /tmp/httpd.conf
cp -f /tmp/httpd.conf /etc/httpd/conf/httpd.conf
/etc/init.d/iptables stop

echo "loadbalancing stuff"
cp /vagrant/src/apache/jboss-lb.conf /etc/httpd/conf.d/
cp /vagrant/src/apache/mod_cluster/*.so /etc/httpd/modules/

cp -f /vagrant/src/apache/hosts /etc/hosts

echo "starting httpd"
apachectl start
