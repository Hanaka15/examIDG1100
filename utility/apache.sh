#!/bin/bash

# Informative message about the CGI script setup.
spacer "Preparing the CGI script..."

# Reading the CGI template and replacing directory placeholders.
CGI_TEMPLATE_CONTENT=$(<"$DYNAMIC_SCRIPT_TEMPLATE")
CGI_SCRIPT_CONTENT=${CGI_TEMPLATE_CONTENT//"%DEST_DIR%"/$DEST_DIR}
echo "$CGI_SCRIPT_CONTENT" > "$CGI_SCRIPT"

# Setting ownership and permissions for the CGI script.
sudo chown www-data:www-data "$CGI_SCRIPT"
sudo chmod 755 "$CGI_SCRIPT"

# Building a list of locations from the data file.
locations=($(tail -n +2 "$DATA_FILE" | cut -d ',' -f 1))

# Creating HTML list elements for each location.
li_elements=""
for name in "${locations[@]}"
do
  href="/cgi-bin/place.sh?query=$name"
  li_elements+="<li><a href=\"$href\">$name</a></li>"
done
location_list_html="<ul>$li_elements</ul>"

# Updating the index page with the location list.
sed -i "s|{{location_list}}|$location_list_html|g" "${DEST_DIR}/public_html/index.html"

# Configuring Apache with necessary settings.
spacer "Setting up Apache..."
sed -e "s|%DEST_DIR%|$DEST_DIR|" \
    -e "s|%ADMIN_EMAIL%|$ADMIN_EMAIL|" \
    -e "s|%SITE_NAME%|$SITE_NAME|" \
    "$APACHE_TEMPLATE" > "$APACHE_SITE_CONF"

# Setting up the script directory and weather update script.
# Essentially i just move the weather python script incase 
# someone deletes the deployment.
sudo mkdir -p "$SCRIPT_DIR"
sudo cp "${UTILITY_DIR}/get_weather.py" "${SCRIPT_DIR}/get_weather.py"
sudo chmod +x "$SCRIPT_DIR"

# Adding host entries and a cron job using my functions defined in the functions file.
# I also set the script to use the data file that
# has been created and put under /data in the sites root folder.
add_hosts "127.0.0.1" "$SITE_NAME"
add_cron_job "0 * * * * ${SCRIPT_DIR}/get_weather.py \"$DATA_FILE\"" "Weather for ${SITE_NAME}"

# Setting perms for public_html and cgi-bin.
sudo find "${DEST_DIR}/public_html" -type d -exec chmod 755 {} \;
sudo find "${DEST_DIR}/public_html" -type f -exec chmod 644 {} \;
sudo chmod -R 755 "${DEST_DIR}/cgi-bin"
sudo chown -R www-data:www-data "$DEST_DIR"

# Enable the site on Apache2 to use.
spacer "Enabling the site..."
sudo a2ensite "$SITE_NAME"
sudo systemctl restart apache2
