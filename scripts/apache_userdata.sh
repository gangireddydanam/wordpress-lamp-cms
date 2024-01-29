#!/bin/bash
#apache installation 
#user data will be executed by root user by default 
#ec2 --root/ec2-user
#install #mysql dependencies, php
sudo dnf install wget php-mysqlnd httpd php-fpm php-mysqli mariadb105-server php-json php php-devel -y
sudo yum update -y 
sudo  yum install httpd -y 
sudo systemctl start httpd 
sudo systemctl enable httpd 

#download wordpress 
cd /tmp
wget https://wordpress.org/latest.zip
unzip latest.zip
ls -ld wordpress/
#copy php code of wordpress into apache path
sudo cp -r wordpress/* /var/www/html/
ls -ltr /var/www/html/
sleep 5 
sudo systemctl restart httpd
 
#node exporter -binary
#cpu/memory/process/loadusage/disc/load avg/uptime/metrics
#download--extract---change permissions--start
wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
tar xvfz node_exporter-*.*-amd64.tar.gz
cd node_exporter-*.*-amd64
./node_exporter




