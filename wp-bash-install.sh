#!/bin/shsudo apt-get update 
sudo apt-get install curl -y 
 

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar 
chmod+x wp-cli.phar 
sudo mvwp-cli.phar /usr/local/bin/wp 
 

cd/var/www/html/ 
sudo wp core download --locale=en_US --allow-root 
sudo wp config create --dbname=wordpress --dbuser=root --dbpass= --allow-root 
sudo wp db create --allow-root 
sudo wp core install --url=localhost --title=Test --admin_user=admin --admin_password=password --admin_email=admin@example.com --allow-root 
 

sudo chown-R www-data:www-data /var/www/html/ 
