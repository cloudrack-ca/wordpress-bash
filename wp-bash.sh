#!/bin/bash
# This script is meant to be run on a fresh install of Ubuntu 18.04 | 20.04 | 22.04 | Debian 11
# This script is meant to be run as root

# Define colors
RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
# Function to display a loading bar
function loading_bar() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}
echo -e "${RED}*******************************************************************************${NC}"
echo "▐▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▌";
echo "▐          ___ _ _   _  _      _       ___     ___ _ _     _           ▌";
echo "▐   ___   / __(_| |_| || |_  _| |__   / __|___| _ (_| |___| |_   ___   ▌";
echo "▐  |___| | (_ | |  _| __ | || | '_ \ | (__/ _ |  _| | / _ |  _| |___|  ▌";
echo "▐         \___|_|\__|_||_|\_,_|_.__/  \___\___|_| |_|_\___/\__|        ▌";
echo "▐▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▌";
echo -e "${RED}*******************************************************************************${NC}"
# echo "this !#/bin/sh script was written with no code by GitHub copilot and time and effort put in by cloudrack.ca" 
echo -e "${BLUE}this !#/bin/sh script was written with no code by GitHub copilot and time and effort put in by https://cloudrack.ca${NC}"

# Get localhost IP
ip=$(hostname -I | awk '{print $1}')
# Tell the user "Let's start installing your WordPress site" in Purple
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
echo -e "${YELLOW}Enter MySQL root password [If none is entered default will be used: my5ql-r0Ot-Pa\$W0Rd]: ${NC}"
read -s -p "(default: my5ql-r0Ot-Pa\$W0Rd) " mysql_root_password
mysql_root_password=${mysql_root_password:-my5ql-r0Ot-Pa\$W0Rd}
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
(add-apt-repository -y ppa:ondrej/php &>> install.log) &
loading_bar $!

# Update apt
echo -e "${GREEN}Updating apt...${NC}"
(apt-get update &>> install.log) &
loading_bar $!

# Install required packages
echo -e "${BLUE}Installing required packages this may take along time depending on your servers setup & specs...${NC}"
apt-get install -y apache2 mysql-server php$php_version libapache2-mod-php$php_version php$php_version-mysql php$php_version-curl php$php_version-gd php$php_version-mbstring php$php_version-xml php$php_version-xmlrpc php$php_version-soap php$php_version-intl php$php_version-zip curl &>> install.log & 
loading_bar $!

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
echo -e "${GREEN}🎉  Tada  🎉  -  Your WordPress installation is complete ${NC}"

# Display user's database info
echo -e "${GREEN}Your WordPress database information:${NC}"
echo -e "${YELLOW}Please don't lose this - Your Database name:${NC} $wp_db_name"
echo -e "${YELLOW}Please don't lose this - Your Database user:${NC} $wp_db_user"
echo -e "${YELLOW}Please don't lose this - Your Database user password:${NC} $wp_db_password"
echo -e "${YELLOW}Please don't lose this - Your Root MySql password: $mysql_root_password${NC}"

# Donate to my projects at https://donate.cloudrack.ca in red & yellow
echo -e "${RED}-------------------------------------------------------------------${NC}"
echo -e "${YELLOW}-------------------------------------------------------------------${NC}"

echo -e "${YELLOW}donate to my projects at https://donate.cloudrack.ca${NC}"
echo -e "${YELLOW}-------------------------------------------------------------------${NC}"
echo -e "${RED}-------------------------------------------------------------------${NC}"

echo -e "\033[0;34m  *******************************************************************************"
echo -e "  *   _____           _       __      ____                                   __ *"
echo -e "  *  / ___/__________(_)___  / /_    / __ \____ _      _____  ________  ____/ / *"
echo -e "  *  \__ \/ ___/ ___/ / __ \/ __/   / /_/ / __ \ | /| / / _ \/ ___/ _ \/ __  /  *"
echo -e "  * ___/ / /__/ /  / / /_/ / /_    / ____/ /_/ / |/ |/ /  __/ /  /  __/ /_/ /   *"
echo -e "  */____/\___/_/  /_/ .___/\__/   /_/    \____/|__/|__/\___/_/   \___/\__,_/    *"
echo -e "  *    ____        /_/________                __                __              *"
echo -e "  *   / __ )__  __   / ____/ /___  __  ______/ /________ ______/ /__ _________ *"
echo -e "  *  / __  / / / /  / /   / / __ \/ / / / __  / ___/ __ \`/ ___/ //_// ___/ __ \`/*"
echo -e "  * / /_/ / /_/ /  / /___/ / /_/ / /_/ / /_/ / /  / /_/ / /__/ ,< _/ /__/ /_/ / *"
echo -e "  */_____/\__, /   \____/_/\____/\__,_/\__,_/_/   \__,_/\___/_/|_(_)___/\__,_/  *"
echo -e "  *      /____/                                                                 *"
echo -e "  *******************************************************************************\033[0m"

# Display localhost IP
ip=$(hostname -I | awk '{print $1}')
echo -e "${YELLOW}your wordpress installation will be on your IPv4 located -> :${NC} $ip"
# echo "and or" in red
echo -e "${YELLOW}and or${NC}"
# Display localhost IPv6
ip6=$(hostname -I | awk '{print $2}')
echo -e "${YELLOW}your wordpress installation will be on your IPv6 located -> :${NC} [$ip6]"
# Display wordpress directory
echo -e "${YELLOW}your wordpress installation directory is -> :${NC} $wp_dir"
# Display PHP version
echo -e "${YELLOW}your wordpress installation wordpress php version is -> :${NC} $php_version"
# Display WordPress version
echo -e "${YELLOW}your wordpress installation wordpress version is -> :${NC} $wp_version"
# display ports used in red
echo -e "${YELLOW}your wordpress installation will be on your IPv4 or ipv6 located -> :${NC} 80 and 443"
# display ipv4 with port 80
echo -e "${YELLOW}your wordpress installation will be on your IPv4 located -> :${NC} $ip:80"
# display ipv4 with port 443
echo -e "${YELLOW}your wordpress installation will be on your IPv4 located -> :${NC} $ip:443"
# display ipv6 with port 80
echo -e "${YELLOW}your wordpress installation will be on your IPv6 located -> :${NC} [$ip6]:80"
# display ipv6 with port 443
echo -e "${YELLOW}your wordpress installation will be on your IPv6 located -> :${NC} [$ip6]:443"
# Get the server's hostname
server_hostname=$(hostname)
# Append ".local" to the hostname
server_hostname_with_local="${server_hostname}.local"
# Prepend "http://" to the hostname
server_hostname_with_http="http://${server_hostname_with_local}"

# Append the modified hostname to the end of the file
echo -e "${YELLOW}your wordpress installation will also be found on your hostname ${server_hostname_with_http}"
# end of file / script
