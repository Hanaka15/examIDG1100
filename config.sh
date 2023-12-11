#Site config
SITE_NAME="weatherly.local"
ADMIN_EMAIL="webmaster@${SITE_NAME}"

DEST_DIR="/var/www/${SITE_NAME}"

# Static variables
# This is just for shortening the paths to keep the scripts cleaner.  
BASE_DIR=$(dirname "$0")
UTILITY_DIR="${BASE_DIR}/utility"
TEMPLATE_DIR="${BASE_DIR}/templates"
TMP_DIR="${BASE_DIR}/tmp"

# Variables for the Apache configuration.
APACHE_SITE_CONF="/etc/apache2/sites-available/${SITE_NAME}.conf"
APACHE_TEMPLATE="${TEMPLATE_DIR}/apache_template.txt"
SCRIPT_DIR="/usr/local/bin/${SITE_NAME}"

# Variables for templates and other stuff. 
DYNAMIC_SCRIPT_TEMPLATE="${TEMPLATE_DIR}/dynamic_template.txt"
WEATHER_TEMPLATE="${TEMPLATE_DIR}/weather_page_template.txt"
INDEX_TEMPLATE="${TEMPLATE_DIR}/index_template.txt"

CGI_SCRIPT="${DEST_DIR}/cgi-bin/place.sh"
DATA_FILE="${DEST_DIR}/data/data.csv"