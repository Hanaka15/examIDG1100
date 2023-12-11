import requests
from bs4 import BeautifulSoup
import concurrent.futures
import csv
import re
import sys

# Converting DMS coordinates to decimals.     
def dms_to_decimal(dms):
    parts = re.split('[°′″]', dms)
    if len(parts) == 4:
        degrees, minutes, seconds, direction = parts
        decimal = float(degrees) + float(minutes)/60 + float(seconds)/3600
        return -decimal if direction in ['S', 'W'] else decimal
    return None

# Function to fetch cordinates from the manipulated sites.
def fetch_municipality_data(name, url):
    try:
        response = requests.get(url)
        response.raise_for_status()
        soup = BeautifulSoup(response.content, 'html.parser')

        # Iterate through each 'geo-dms' element
        for geo_dms in soup.find_all('span', {'class': 'geo-dms'}):
            # Find latitude and longitude spans
            latitude_span = geo_dms.find('span', {'class': 'latitude'})
            longitude_span = geo_dms.find('span', {'class': 'longitude'})

            # Convert DMS to decimal and check for validity
            if latitude_span and longitude_span:
                latitude = dms_to_decimal(latitude_span.get_text(strip=True))
                longitude = dms_to_decimal(longitude_span.get_text(strip=True))
                if latitude != 'Not available' and longitude != 'Not available':
                    return name, url, latitude, longitude
        return name, url, 'Not available', 'Not available'
    except Exception:
        return name, url, 'Error', 'Error'
    
def main(input_html_file, output_csv_file):
    # Read HTML file and parse with BeautifulSoup
    with open(input_html_file, 'r', encoding='utf-8') as file:
        soup = BeautifulSoup(file, 'html.parser')

    # Extract municipality names and URLs from the table
    table = soup.find('table', {'class': 'wikitable'})
    municipalities = [
        (row.find('a').get_text(strip=True), 'https://en.wikipedia.org' + row.find('a')['href'])
        for row in table.find_all('tr')[1:] if row.find('a')
    ]

    # Concurrently fetch data for each municipality
    with concurrent.futures.ThreadPoolExecutor() as executor:
        results = [result for result in executor.map(fetch_municipality_data, *zip(*municipalities)) if result]

    # Write the results to the CSV file
    with open(output_csv_file, 'w', newline='', encoding='utf-8') as file:
        writer = csv.writer(file)
        writer.writerow(['Name', 'URL', 'Latitude', 'Longitude'])
        writer.writerows(results)

# Script execution starts here
if __name__ == "__main__":
    # Ensure correct usage
    if len(sys.argv) < 3:
        print("Usage: script.py <input_html_file> <output_csv_file>")
        sys.exit(1)
    main(sys.argv[1], sys.argv[2])
    
    # Notify completion
    print("Municipality data extraction complete.")
