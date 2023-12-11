# Splitting the git perma url.
REPO="metno/weathericons"
BRANCH="89e3173756248b4696b9b10677b66c4ef435db53" 
DIR_PATH="weather/svg" 

API_URL="https://api.github.com/repos/$REPO/contents/$DIR_PATH?ref=$BRANCH"

# Checking for the last icon in the repo. 
# if this is gone then most likely the rest of the icons are not downloaded aswell. 
# does not take into account if some of the icons are deleted though. but should be fine for this.
if [ ! -f "${DEST_DIR}/public_html/weather_icons/snowshowersandthunder_polartwilight.svg" ]; then

spacer  "Downloading icons"

DOWNLOAD_DIR="${DEST_DIR}/public_html/weather_icons"
mkdir -p "$DOWNLOAD_DIR" # Creating directory. 
json=$(curl -s "$API_URL") # Getting the icons.

urls=$(echo "$json" | grep -oP '"download_url": "\K(.*?)(?=")')

# Go through the icons and download them
echo "$urls" | while read -r url; do
    if [[ $url == *.svg ]]; then
        file=$(basename "$url")
        echo "Downloading $file"
        curl -s -L -o "$DOWNLOAD_DIR/$file" "$url"
    fi
done
spacer "Download complete."
else
    echo "icons already downloaded." # Dont need to download them twice. 
fi