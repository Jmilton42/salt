#!/bin/bash
sudo mysql -e "RENAME USER 'root'@'localhost' TO 'root'@'%';"
