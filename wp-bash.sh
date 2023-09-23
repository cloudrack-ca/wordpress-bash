#!/bin/bash script that will allow me to install wordpress & wordpress cli on my local machine as well as set the requrired php.ini settings
# This script is meant to be run on a fresh install of Ubuntu 18.04 LTS
# This script is meant to be run as root
#!/bin/bash

# Add PHP 8.1 repository
add-apt-repository ppa:ondrej/php
apt-get update

# Install required packages
apt-get install -y apache2 mysql-server php8.1 libapache2-mod-php8.1 php8.1-mysql php8.1-curl php8.1-gd php8.1-mbstring php8.1-xml php8.1-xmlrpc php8.1-soap php8.1-intl php8.1-zip curl

# Download and extract WordPress
curl -O https://wordpress.org/latest.tar.gz
tar -zxvf latest.tar.gz
mv wordpress /var/www/html/
chown -R www-data:www-data /var/www/html/wordpress
chmod -R 755 /var/www/html/wordpress

# Install WordPress CLI
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

# Set PHP.ini settings
mkdir -p /etc/php/8.1/apache2/
touch /etc/php/8.1/apache2/php.ini
sed -i 's/memory_limit = .*/memory_limit = 256M/' /etc/php/8.1/apache2/php.ini
sed -i 's/upload_max_filesize = .*/upload_max_filesize = 64M/' /etc/php/8.1/apache2/php.ini
sed -i 's/post_max_size = .*/post_max_size = 64M/' /etc/php/8.1/apache2/php.ini

# Restart Apache
systemctl restart apache2
