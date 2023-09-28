#!/bin/bash
# This script is meant to be run on a fresh install of Ubuntu 18.04 LTS
# This script is meant to be run as root

# Define colors
RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get localhost IP
ip=$(hostname -I | awk '{print $1}')
# Tell the user "Lets start installing your WordPress site" in Purple
echo -e "${BLUE}Lets start installing your WordPress site simply follow the steps to install.${NC}"
# Prompt user to define PHP version
echo -e "${YELLOW}Enter PHP version (e.g. 8.1) [If none is entered default will be used: 8.1]: ${NC}"
read -p "(default: 8.1) " php_version
php_version=${php_version:-8.1}
echo -e "${GREEN}Using PHP version: $php_version${NC}"

# Prompt user to define WordPress version
echo -e "${YELLOW}Enter WordPress version (e.g. latest) [If none is entered default will be used: latest]: ${NC}"
read -p "(default: latest) " wp_version
wp_version=${wp_version:-latest}
echo -e "${GREEN}Using WordPress version: $wp_version${NC}"

# Prompt user to define WordPress directory
echo -e "${YELLOW}Enter WordPress directory (e.g. /var/www/html/wordpress) [If none is entered default will be used: /var/www/html/wordpress]: ${NC}"
read -p "(default: /var/www/html/wordpress) " wp_dir
wp_dir=${wp_dir:-/var/www/html/wordpress}
echo -e "${GREEN}Using WordPress directory: $wp_dir${NC}"

# Prompt user to define MySQL root password
echo -e "${YELLOW}Enter MySQL root password [If none is entered default will be used: root]: ${NC}"
read -s -p "(default: root) " mysql_root_password
mysql_root_password=${mysql_root_password:-root}
echo -e "${GREEN}Using MySQL root password: $mysql_root_password${NC}"

# Prompt user to define WordPress database name
echo -e "${YELLOW}Enter WordPress database name [If none is entered default will be used: wordpress_db]: ${NC}"
read -p "(default: wordpress_db) " wp_db_name
wp_db_name=${wp_db_name:-wordpress_db}
echo -e "${GREEN}Using WordPress database name: $wp_db_name${NC}"

# Prompt user to define WordPress database user
echo -e "${YELLOW}Enter WordPress database user [If none is entered default will be used: wordpress_user]: ${NC}"
read -p "(default: wordpress_user) " wp_db_user
wp_db_user=${wp_db_user:-wordpress_user}
echo -e "${GREEN}Using WordPress database user: $wp_db_user${NC}"

# Prompt user to define WordPress database user password
echo -e "${YELLOW}Enter WordPress database user password [If none is entered default will be used: password]: ${NC}"
read -s -p "(default: password) " wp_db_password
wp_db_password=${wp_db_password:-password}
echo -e "${GREEN}Using WordPress database user password: $wp_db_password${NC}"

# Add PHP repository
echo -e "${BLUE}Adding PHP $php_version repository...${NC}"
add-apt-repository -y ppa:ondrej/php &>> install.log

# Update apt
echo -e "${GREEN}Updating apt...${NC}"
apt-get update &>> install.log

# Install required packages
echo -e "${BLUE}Installing required packages...${NC}"
apt-get install -y apache2 mysql-server php$php_version libapache2-mod-php$php_version php$php_version-mysql php$php_version-curl php$php_version-gd php$php_version-mbstring php$php_version-xml php$php_version-xmlrpc php$php_version-soap php$php_version-intl php$php_version-zip curl &>> install.log

# Create WordPress database and user
echo -e "${BLUE}Creating WordPress database and user...${NC}"
mysql -u root -p$mysql_root_password -e "CREATE DATABASE $wp_db_name;"
mysql -u root -p$mysql_root_password -e "CREATE USER '$wp_db_user'@'localhost' IDENTIFIED BY '$wp_db_password';"
mysql -u root -p$mysql_root_password -e "GRANT ALL PRIVILEGES ON $wp_db_name.* TO '$wp_db_user'@'localhost';"
mysql -u root -p$mysql_root_password -e "FLUSH PRIVILEGES;"

# Download and extract WordPress
echo -e "${BLUE}Downloading and extracting WordPress $wp_version...${NC}"
wget -q https://wordpress.org/$wp_version.tar.gz -O - | tar -xz -C /tmp &>> install.log
mv /tmp/wordpress $wp_dir
chown -R www-data:www-data $wp_dir
chmod -R 755 $wp_dir

# Configure Apache to serve WordPress
echo -e "${BLUE}Configuring Apache to serve WordPress...${NC}"
cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/wordpress.conf
sed -i "s|DocumentRoot /var/www/html|DocumentRoot $wp_dir|" /etc/apache2/sites-available/wordpress.conf
sed -i "s|<Directory /var/www/html>|<Directory $wp_dir>|" /etc/apache2/sites-available/wordpress.conf
a2dissite 000-default.conf &>> install.log
a2ensite wordpress.conf &>> install.log
systemctl reload apache2 &>> install.log

# Install WordPress CLI
echo -e "${BLUE}Installing WordPress CLI...${NC}"
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar &>> install.log
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

# Set PHP.ini settings
echo -e "${BLUE}Setting PHP.ini settings...${NC}"
mkdir -p /etc/php/$php_version/apache2/
touch /etc/php/$php_version/apache2/php.ini
sed -i 's/memory_limit = .*/memory_limit = 256M/' /etc/php/$php_version/apache2/php.ini
sed -i 's/upload_max_filesize = .*/upload_max_filesize = 64M/' /etc/php/$php_version/apache2/php.ini
sed -i 's/post_max_size = .*/post_max_size = 64M/' /etc/php/$php_version/apache2/php.ini

# Restart Apache
echo -e "${GREEN}Restarting Apache...${NC}"
systemctl restart apache2 &>> install.log
# Tada Your WordPress installation is complete in cyan
echo -e "${BLUE}🎉 Tada 🎉 Your WordPress installation is complete${NC}"
# Display user's database info
echo -e "${BLUE}Your WordPress database information:${NC}"
echo -e "${YELLOW}Please dont lose this - Your Database name:${NC} $wp_db_name"
echo -e "${YELLOW}Please dont lose this - Your Database user:${NC} $wp_db_user"
echo -e "${YELLOW}Please dont lose this - Your Database user password:${NC} $wp_db_password"

# Display localhost IP
echo -e "${BLUE}your wordpress installation will be on your IP located -> :${NC} $ip"
# Display wordpress directory
echo -e "${BLUE}your wordpress installation will be on your IP located -> :${NC} $wp_dir"
# Display PHP version
echo -e "${BLUE}your wordpress installation will be on your IP located -> :${NC} $php_version"
# Display WordPress version
echo -e "${BLUE}your wordpress installation will be on your IP located -> :${NC} $wp_version"
