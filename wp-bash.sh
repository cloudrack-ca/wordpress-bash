#!/bin/bash

# Define default variables
WORDPRESS_VERSION="latest"
DB_NAME="wordpress"
DB_USER="wordpress"
DB_PASSWORD="password"
DB_HOST="localhost"
LOG_FILE="/var/log/install-wordpress.log"

# Define functions
log() {
    echo "$(date) - $1" >> $LOG_FILE
}

install_packages() {
    log "Installing required packages..."
    apt-get update
    apt-get install -y apache2 mysql-server php8.1 libapache2-mod-php8.1 php8.1-mysql php8.1-curl php8.1-gd php8.1-mbstring php8.1-xml php8.1-xmlrpc php8.1-soap php8.1-intl php8.1-zip curl
}

download_wordpress() {
    log "Downloading WordPress..."
    curl -O https://wordpress.org/$WORDPRESS_VERSION.tar.gz
    tar -zxvf $WORDPRESS_VERSION.tar.gz
    mv wordpress /var/www/html/
    chown -R www-data:www-data /var/www/html/wordpress
    chmod -R 755 /var/www/html/wordpress
}

configure_apache() {
    log "Configuring Apache to serve WordPress..."
    cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/wordpress.conf
    sed -i 's/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www\/html\/wordpress/' /etc/apache2/sites-available/wordpress.conf
    sed -i 's/Directory \/var\/www\/html/Directory \/var\/www\/html\/wordpress/' /etc/apache2/sites-available/wordpress.conf
    a2dissite 000-default.conf
    a2ensite wordpress.conf
    systemctl reload apache2
}

install_wp_cli() {
    log "Installing WordPress CLI..."
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
}

configure_php() {
    log "Configuring PHP settings..."
    mkdir -p /etc/php/8.1/apache2/
    touch /etc/php/8.1/apache2/php.ini
    sed -i 's/memory_limit = .*/memory_limit = 256M/' /etc/php/8.1/apache2/php.ini
    sed -i 's/upload_max_filesize = .*/upload_max_filesize = 64M/' /etc/php/8.1/apache2/php.ini
    sed -i 's/post_max_size = .*/post_max_size = 64M/' /etc/php/8.1/apache2/php.ini
}

create_database() {
    log "Creating database..."
    mysql -u$DB_USER -p"$DB_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
}

configure_wordpress() {
    log "Configuring WordPress..."
    cd /var/www/html/wordpress
    wp core config --dbname=$DB_NAME --dbuser=$DB_USER --dbpass="$DB_PASSWORD" --dbhost=$DB_HOST --extra-php <<PHP
define( 'WP_DEBUG', true );
define( 'WP_DEBUG_LOG', true );
PHP
    wp core install --url=http://example.com --title="My WordPress Site" --admin_user=admin --admin_password=password --admin_email=admin@example.com
}

# Parse command line arguments
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        -v|--version)
        WORDPRESS_VERSION="$2"
        shift # past argument
        shift # past value
        ;;
        -n|--name)
        DB_NAME="$2"
        shift # past argument
        shift # past value
        ;;
        -u|--user)
        DB_USER="$2"
        shift # past argument
        shift # past value
        ;;
        -p|--password)
        DB_PASSWORD="$2"
        shift # past argument
        shift # past value
        ;;
        -h|--host)
        DB_HOST="$2"
        shift # past argument
        shift # past value
        ;;
        *)    # unknown option
        shift # past argument
        ;;
    esac
done

# Main script
log "Starting WordPress installation..."

# Install required packages
install_packages || { log "Error installing packages"; exit 1; }

# Download and extract WordPress
download_wordpress || { log "Error downloading WordPress"; exit 1; }

# Configure Apache to serve WordPress
configure_apache || { log "Error configuring Apache"; exit 1; }

# Install WordPress CLI
install_wp_cli || { log "Error installing WP CLI"; exit 1; }

# Set PHP.ini settings
configure_php || { log "Error configuring PHP"; exit 1; }

# Create database
create_database || { log "Error creating database"; exit 1; }

# Configure WordPress
configure_wordpress || { log "Error configuring WordPress"; exit 1; }

log "WordPress installation complete."
