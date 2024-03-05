#!/bin/bash

# Install Apache
yam update -y
yum install -y httpd
echo "Hello World from $(hostname -f)" > /var/www/html/index.html
sudo service httpd start
sudo chkconfig httpd on

