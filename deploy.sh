#!/bin/bash

# Getting the config and the fucntions script.
# Helps keep the deploymen script clean.
source ./config.sh
source $UTILITY_DIR/functions.sh

# Check if Python and pip are installed
if ! command_exists python3 || ! command_exists pip3; then # Uses the function in the functions script.
    spacer "Missing: Python 3 | pip3"
    exit 1
fi

# Installs the python modules. 
# Does not matter if it runs twice. it will just "requirements are satisfied"
spacer "Attempting pip install..."
pip3 install requests beautifulsoup4 --user > /dev/null 2>&1

# Create directories and files
mkdir -p "${DEST_DIR}/cgi-bin"
mkdir -p "${DEST_DIR}/public_html"
mkdir -p "${DEST_DIR}/data"

cp -n $INDEX_TEMPLATE "$DEST_DIR/public_html/index.html" # Copying the template to the index of the site.
cp $WEATHER_TEMPLATE "${DEST_DIR}/cgi-bin/template.html" # Copying the html template for the CGI Script.

# Running the script to download the icons.
source $UTILITY_DIR/icons.sh

# Checking if the data file exists.
# This just creates the tmp dir, run python and then cleanup. 
if [ ! -f "$DATA_FILE" ]; then
    spacer "Running the Python script..."
    mkdir -p $TMP_DIR
    curl "https://en.wikipedia.org/wiki/List_of_municipalities_of_Norway" > "${TMP_DIR}/municipalities.html" 
    python3 "$UTILITY_DIR/extract.py" "${TMP_DIR}/municipalities.html" "$DATA_FILE"
    rm -r $TMP_DIR
fi

# running the get_weather.py script
spacer "Getting Weather data"
python3 "$UTILITY_DIR/get_weather.py" "$DATA_FILE"

# running the apache.sh script
# this is just to configure the apache and the hosts and cron job.
source $UTILITY_DIR/apache.sh

spacer "Deployment complete."
