REPO="metno/weathericons"
BRANCH="89e3173756248b4696b9b10677b66c4ef435db53" 
DIR_PATH="weather/svg" 

API_URL="https://api.github.com/repos/$REPO/contents/$DIR_PATH?ref=$BRANCH"

if [ ! -f "${DEST_DIR}/public_html/weather_icons/snowshowersandthunder_polartwilight.svg" ]; then
spacer  "Downloading icons"

DOWNLOAD_DIR="${DEST_DIR}/public_html/weather_icons"

mkdir -p "$DOWNLOAD_DIR"

json=$(curl -s "$API_URL")

urls=$(echo "$json" | grep -oP '"download_url": "\K(.*?)(?=")')

echo "$urls" | while read -r url; do
    if [[ $url == *.svg ]]; then
        file=$(basename "$url")
        echo "Downloading $file"
        curl -s -L -o "$DOWNLOAD_DIR/$file" "$url"
    fi
done
spacer "Download complete."
else
    echo "icons already downloaded."
fi