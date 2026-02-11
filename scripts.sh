#!/bin/bash
set -e

# Update package 
apt update -y

# Install Apache, PHP, and required extensions
apt install -y apache2 mysql-client php php-mysql php-curl php-gd php-intl php-mbstring php-xml php-zip unzip wget

# Enable and start Apache
systemctl enable apache2
systemctl start apache2

# Clean web directory
rm -rf /var/www/html/*

# Downloading PrestaShop (Classic version) and unzip correctly
cd /tmp
wget https://download.prestashop.com/download/releases/prestashop_edition_basic_version_9.0.3-3.0.zip
unzip prestashop_edition_basic_version_9.0.3-3.0.zip
unzip prestashop.zip

# Move extracted files to web root
mv prestashop/* /var/www/html/

# permissions for Apache
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Wait for RDS to be available
echo "Waiting for RDS database..."
until mysql -h "${db_host}" -u "${db_user}" -p"${db_password}" -e "SELECT 1" >/dev/null 2>&1; do
  sleep 10
done

# Create the database if it doesn't exist
mysql -h "${db_host}" -u "${db_user}" -p"${db_password}" -e "CREATE DATABASE IF NOT EXISTS ${db_name};"

echo "PrestaShop setup is ready. Open your browser to complete the installation."
  