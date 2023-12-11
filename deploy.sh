#!/bin/bash

source ./config.sh
source $UTILITY_DIR/functions.sh

# Check if Python and pip are installed
if ! command_exists python3 || ! command_exists pip3; then
    spacer "Missing: Python 3 | pip3"
    exit 1
fi

spacer "Attempting pip install..."
pip3 install requests beautifulsoup4 --user > /dev/null 2>&1

# Create directories and files
mkdir -p "${DEST_DIR}/cgi-bin"
mkdir -p "${DEST_DIR}/public_html"
mkdir -p "${DEST_DIR}/data"

cp -n $INDEX_TEMPLATE "$DEST_DIR/public_html/index.html"
cp $WEATHER_TEMPLATE "${DEST_DIR}/cgi-bin/template.html"

source $UTILITY_DIR/icons.sh

if [ ! -f "$DATA_FILE" ]; then
    spacer "Running the Python script..."
    mkdir -p $TMP_DIR
    curl "https://en.wikipedia.org/wiki/List_of_municipalities_of_Norway" > "${TMP_DIR}/municipalities.html" 
    python3 "$UTILITY_DIR/extract.py" "${TMP_DIR}/municipalities.html" "$DATA_FILE"
    rm -r $TMP_DIR
fi

spacer "Getting Weather data"
#python3 "$UTILITY_DIR/get_weather.py" "$DATA_FILE"

source $UTILITY_DIR/apache.sh

spacer "Deployment complete."
