#! /bin/bash
sudo apt-get update
sudo sudo apt install apache2
sudo rm -rf /var/www/html/index.html
sudo wget -O /var/www/html/index.html https://raw.githubusercontent.com/panazzo/multi-cloud-deployer/master/site/index.html
sudo sed -i -e 's/{{CLOUD}}/AZURE/g' /var/www/html/index.html

