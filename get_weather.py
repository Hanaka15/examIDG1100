import requests
import csv
from datetime import datetime

def fetch_weather_data(lat, lon):
    base_url = "https://api.met.no/weatherapi/locationforecast/2.0/classic"
    headers = {
        'User-Agent': 'WeatherWebsite/1.0 (jahnaagh@ntnu.no)'
    }
    params = {
        'lat': lat,
        'lon': lon,
        'altitude': 90  # Assuming a constant altitude of 90 meters
    }
    response = requests.get(base_url, headers=headers, params=params)
    if response.status_code == 200:
        return response.json()
    else:
        return None

csv_file = 'data.csv'

# Read the CSV file for latitude and longitude
with open(csv_file, 'r', encoding='utf-8') as file:
    reader = csv.reader(file)
    header = next(reader)
    locations = [row for row in reader]

# Fetch weather data for each location
for location in locations:
    name, _, latitude, longitude = location
    weather = fetch_weather_data(latitude, longitude)
    if weather:
        current_time = datetime.now().isoformat()
        timeseries = weather.get('properties', {}).get('timeseries', [])
        current_weather = next((item for item in timeseries if item['time'] > current_time), None)

        if current_weather:
            temp = current_weather['data']['instant']['details']['air_temperature']
            location.append(temp)
        else:
            location.append('Data not available')
    else:
        location.append('Data not available')

# Add the 'Temperature' column to the header
header.append('Temperature')

# Write the updated data back to the CSV file
with open(csv_file, 'w', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)
    writer.writerow(header)
    writer.writerows(locations)

print("Weather data update complete.")
