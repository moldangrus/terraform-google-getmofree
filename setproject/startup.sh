#!/bin/bash
apt-get install -y apache2
systemctl enable apache2
systemctl start apache2
