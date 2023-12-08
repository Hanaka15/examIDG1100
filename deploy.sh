#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check if Python is installed.
if ! command_exists python3; then
    echo "Python 3 is not installed. Please install Python 3."
    exit 1
fi

# Check if pip is installed as it's required to install the modules.
if command_exists pip3; then
    PIP_CMD=pip3
elif command_exists pip; then
    PIP_CMD=pip
else
    echo "pip is not installed. Please install pip."
    exit 1
fi

# Install the Python modules needed to run the extract.py
echo "Installing required Python modules..."
$PIP_CMD install requests beautifulsoup4

# Run the extractor script to extract the table and coordinates.
echo "Running the Python script..."
python3 ./extract.py

