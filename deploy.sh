#!/bin/bash

# Configuration Variables
SITE_NAME="Weatherly.local"
ADMIN_EMAIL="admin@example.com"

# Variables that don't need to be changed
TEMPLATE_DIR="./templates"
DEST_DIR="/var/www/${SITE_NAME}"
APACHE_SITE_CONF="/etc/apache2/sites-available/${SITE_NAME}.conf"
DYNAMIC_SCRIPT_TEMPLATE="${TEMPLATE_DIR}/dynamic_template.txt"
WEATHER_PAGE_TEMPLATE="${TEMPLATE_DIR}/weather_page_template.html"
DATA_FILE="${DEST_DIR}/data/data.csv"

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check if Python and pip are installed
if ! command_exists python3 || ! command_exists pip3; then
    echo "Missing: Python 3 and pip3"
    exit 1
fi

# Install required Python modules
echo "Installing required Python modules..."
pip3 install requests beautifulsoup4 --user

# Create directories
mkdir -p "${DEST_DIR}/cgi-bin"
mkdir -p "${DEST_DIR}/public_html"

# Run the extractor script to fetch and save data
echo "Running the Python script..."
python3 ./extract.py "${DEST_DIR}/municipalities.html" "$DATA_FILE"

# Prepare and deploy the CGI script
echo "Preparing the CGI script..."
sed -e "s|%DATA_FILE%|$DATA_FILE|" \
    -e "s|%PAGE_TEMPLATE%|\$(<"$WEATHER_PAGE_TEMPLATE")|" \
    "$DYNAMIC_SCRIPT_TEMPLATE" > "${DEST_DIR}/cgi-bin/place.sh"
chmod +x "${DEST_DIR}/cgi-bin/place.sh"

# Set Up Apache Configuration
echo "Setting up Apache configuration..."
sed -e "s|%DEST_DIR%|$DEST_DIR|" \
    -e "s|%ADMIN_EMAIL%|$ADMIN_EMAIL|" \
    "$APACHE_TEMPLATE" > "$APACHE_SITE_CONF"

# Enable the site and restart Apache
echo "Enabling the site and restarting Apache..."
sudo a2ensite "${SITE_NAME}"
sudo systemctl restart apache2

echo "Deployment complete."
