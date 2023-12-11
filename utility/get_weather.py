import requests
import json
import csv
from datetime import datetime
import concurrent.futures
import sys

# Constants for the API and the user agent
BASE_URL = "https://api.met.no/weatherapi/locationforecast/2.0/compact"
HEADERS = {'User-Agent': 'Weatherly/1.0 (your_email@example.com)'}  # Replace with your email

def fetch_weather_data(location):
    # Unpack location data
    name, lat, lon = location
    params = {'lat': lat, 'lon': lon}

    try:
        # Send request to https://api.met.no to get weather data.
        response = requests.get(BASE_URL, headers=HEADERS, params=params)
        response.raise_for_status()
        weather_data = response.json()

        # Parse weather data to get current temperature and forecast
        current_time = datetime.now().isoformat()
        timeseries = weather_data.get('properties', {}).get('timeseries', [])
        current_weather = next((item for item in timeseries if item['time'] > current_time), None)

        # Get temperature and forecast data from current weather data
        if current_weather:
            temp = current_weather['data']['instant']['details']['air_temperature']
            forecast = current_weather['data']['next_1_hours']['summary']['symbol_code']
            # Print current temperature and forecast.
            # print(name, temp, forecast) 
            return name, lat, lon, temp, forecast
    except Exception as e:  # basic error handling to keep the script running
        print(f"Error for {name}: {e}")

    return name, lat, lon, 'No data', 'Unknown'

def main(csv_file):
    # Read locations and check if headers exist
    with open(csv_file, 'r', encoding='utf-8') as file:
        reader = csv.DictReader(file)
        locations = [(row['Name'], row['Latitude'], row['Longitude']) for row in reader]
        fieldnames = reader.fieldnames

    # Fetch weather data concurrently using concurrent.futures.
    with concurrent.futures.ThreadPoolExecutor() as executor:
        results = list(executor.map(fetch_weather_data, locations))

    # Update CSV file with new weather data 
    with open(csv_file, 'w', newline='', encoding='utf-8') as file:
        writer = csv.DictWriter(file, fieldnames=fieldnames + ['Temperature', 'Forecast'])
        writer.writeheader()
        for row in results:
            writer.writerow({'Name': row[0], 'Latitude': row[1], 'Longitude': row[2], 'Temperature': row[3], 'Forecast': row[4]})

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: script.py <csv_file>")
        sys.exit(1)
    main(sys.argv[1])
    print("Weather data update complete.")
