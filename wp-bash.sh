#!/bin/bash script that will allow me to install wordpress & wordpress cli on my local machine as well as set the requrired php.ini settings
# This script is meant to be run on a fresh install of Ubuntu 18.04 LTS
# This script is meant to be run as root
#!/bin/bash

# Install required packages
apt-get update
apt-get install -y apache2 mysql-server php libapache2-mod-php php-mysql php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip curl

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
sed -i 's/memory_limit = .*/memory_limit = 256M/' /etc/php/7.2/apache2/php.ini
sed -i 's/upload_max_filesize = .*/upload_max_filesize = 64M/' /etc/php/7.2/apache2/php.ini
sed -i 's/post_max_size = .*/post_max_size = 64M/' /etc/php/7.2/apache2/php.ini

# Restart Apache
systemctl restart apache2
