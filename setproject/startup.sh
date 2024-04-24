#!/bin/bash
sudo yum install httpd -y
sudo yum install apache2 -y
sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl start apache2
sudo systemctl enable apache2
hostname > /var/www/html/index.html