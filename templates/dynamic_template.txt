#!/bin/bash

# Setting up our log file.
LOG_FILE="%DEST_DIR%/cgi-bin/logfile.log"

# sends all our error messages to the log file.
exec 2>>"$LOG_FILE"

# Telling the browser we are serving HTML.
echo "Content-Type: text/html"
echo ""

echo "Script started at $(date)" >&2

# We get the location query from the URL.
LOCATION_QUERY=$(echo "$QUERY_STRING" | sed -n 's/^.*query=\([^&]*\).*$/\1/p' | tr '+' ' ')
# And this bit deals with URL encoded characters.
LOCATION_QUERY=$(printf '%b' "${LOCATION_QUERY//%/\\x}")

# Outputting what location we are dealing with.
echo "Location query: $LOCATION_QUERY" >&2

# Paths for the HTML template and the data file.
# This gets filled once the script gets deployed.
TEMPLATE_PATH="%DEST_DIR%/cgi-bin/template.html"
CSV_FILE_PATH="%DEST_DIR%/data/data.csv"

# Defaulting values as 404 if we dont find the query.
# This is not exactly a 404 page but it does show 404. 
LOCATION="404 Not Found"
TEMPERATURE=""
FORECAST=""

# Loop through the CSV and getting our location.
while IFS=, read -r name url lat lon temp forecast rest; do
    # Trimming carriage returns. Found this online.
    # Fixes an issue where the script combines Temp and Forecast
    name=$(echo "$name" | tr -d '\r')
    url=$(echo "$url" | tr -d '\r')
    lat=$(echo "$lat" | tr -d '\r')
    lon=$(echo "$lon" | tr -d '\r')
    temp=$(echo "$temp" | tr -d '\r')
    forecast=$(echo "$forecast" | tr -d '\r')

    # A bit of debug output.
    echo "Read values: |$name| |$url| |$lat| |$lon| |$temp| |$forecast|" >&2

    # If we've got a match for our location, we'll update our variables.
    if [[ "${name,,}" == "${LOCATION_QUERY,,}" ]]; then
        LOCATION="$name"
        TEMPERATURE="$temp"
        FORECAST="$forecast"
        echo "Match found: |$LOCATION| |$TEMPERATURE| |$FORECAST|" >&2
        break
    fi
done < "$CSV_FILE_PATH"

# In case we didn't find the location, we log that.
# this is not realy needed as we have the defualt value but more for debugging.
if [[ "$LOCATION" == "404 Not Found" ]]; then
    echo "Location not found: $LOCATION_QUERY" >&2
else
    # if it found it, we log the details.
    echo "Location found: $LOCATION, $TEMPERATURE, $FORECAST" >&2
fi

# Getting the HTML template so we can fill it in.
TEMPLATE=$(<"$TEMPLATE_PATH")

# Replacing placeholders in the template with information.
TEMPLATE=${TEMPLATE//"%LOCATION%"/$LOCATION}
TEMPLATE=${TEMPLATE//"%TEMPERATURE%"/$TEMPERATURE}
TEMPLATE=${TEMPLATE//"%FORECAST%"/$FORECAST}

# Outputting the html
echo "$TEMPLATE"

# Logging the script's end time.
echo "Script ended at $(date)" >&2
