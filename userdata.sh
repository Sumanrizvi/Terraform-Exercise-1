#!/bin/bash

sudo su
apt-get update -y
apt-get upgrade -y
apt-get install apache2
systemctl start apache2
systemctl enable apache2
cd /var/www/html



