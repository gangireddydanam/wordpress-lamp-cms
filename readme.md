pre-req:
https://wordpress.org/download/
Recommend PHP 7.4 or greater and MySQL version 5.7 or MariaDB version 10.4 or greater


steps for vpc
1. create vpc (10.2.0.0/16)
2. create subnets (9 subnets-each zone wise)
-=------------------------------------------
app-subnet--10k--30k--cidr range /18 -48-
app-subnet1 - 10.2.0.0/18---10.2.63.254
app-subnet2 -10.2.64.0/18---10.2.127.254
app-subnet3 -10.2.128.0/18-10.2.191.254


data-subnet -8k-24k--cidr range - /21- 6
-=------------------------------------------
data-subnet1 - 10.2.192.0/21---10.2.199.254
data-subnet2 -10.2.200.0/21---10.2.207.254
data-subnet3 -10.2.208.0/21-10.2.215.254


public-subnet-256-1k--cidr range- /24 - 1k
-=------------------------------------------
public-subnet1 - 10.2.216.0/24---10.2.216.254
public-subnet2 -10.2.217.0/24---10.2.217.254
public-subnet3 -10.2.218.0/24-10.2.218.254



tell me your project 
wordpress---framework 
vpc,s3 bucket, app, bastion 
wordpres: static websites/media(news media)/shoppingcarts 
users --reading news--users
agents --publish the news---admin

wordpress-resource--LAMP--linux, apache, mysql, php 
-----------------------------------------------
vpc
ec2 --private subnet--apache
load balancer (alb)--publicsubnet
security group
rds (mysql)
cache 
s3 
cloudfront 
route53



terraform state 
--------------------
store in s3 and enable s3 versioning -sensitive-tf-state-env
terraform state lock ---DyanmoDB--table--lock 


commands 
-------
init
plan 
apply 
outputs
show
console
validate/fmt
state 
-target 


#wordpress
[ec2-user@ip-10-2-15-6 tmp]$ php --version
PHP 8.2.9 (cli) (built: Aug  3 2023 11:39:08) (NTS gcc x86_64)
Copyright (c) The PHP Group
Zend Engine v4.2.9, Copyright (c) Zend Technologies
    with Zend OPcache v8.2.9, Copyright (c), by Zend Technologies
[ec2-user@ip-10-2-15-6 tmp]$

dnf install wget php-mysqlnd httpd php-fpm php-mysqli mariadb105-server php-json php php-devel -y