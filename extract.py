import requests
from bs4 import BeautifulSoup
import concurrent.futures
import csv

# Function to fetch municipality data
def fetch_municipality_data(url):
    response = requests.get(url)
    soup = BeautifulSoup(response.content, 'html.parser')
    latitude = soup.find('span', {'class': 'latitude'}).get_text(strip=True) if soup.find('span', {'class': 'latitude'}) else 'Not available'
    longitude = soup.find('span', {'class': 'longitude'}).get_text(strip=True) if soup.find('span', {'class': 'longitude'}) else 'Not available'
    return url, latitude, longitude

# URL of the Wikipedia page
url = 'https://en.wikipedia.org/wiki/List_of_municipalities_of_Norway'

# Fetch the page
response = requests.get(url)
soup = BeautifulSoup(response.content, 'html.parser')

# Find the table
table = soup.find('table', {'class': 'wikitable'})

# Prepare list of URLs for multithreading
municipalities = []
for row in table.find_all('tr')[1:]:
    cols = row.find_all('td')
    if cols:
        name = cols[1].get_text(strip=True)
        municipality_url = 'https://en.wikipedia.org' + cols[1].find('a')['href']
        municipalities.append((name, municipality_url))

# Fetch data in parallel
with concurrent.futures.ThreadPoolExecutor() as executor:
    results = executor.map(lambda x: fetch_municipality_data(x[1]), municipalities)

# Save the data to a CSV file
with open('municipalities_data.csv', 'w', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)
    writer.writerow(['Name', 'URL', 'Latitude', 'Longitude'])
    for name, (url, latitude, longitude) in zip(municipalities, results):
        writer.writerow([name[0], url, latitude, longitude])

print("Municipality data extraction complete.")
