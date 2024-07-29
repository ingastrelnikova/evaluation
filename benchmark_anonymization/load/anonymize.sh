#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR=$(dirname "$0")

# Define the base directory for JSON data
BASE_JSON_DIR="$SCRIPT_DIR/json_data"
URL="http://localhost:8080/anonymize/patients"

if [ ! -d "$BASE_JSON_DIR" ]; then
    echo "Directory $BASE_JSON_DIR does not exist."
    exit 1
fi

for DIR in $BASE_JSON_DIR/*; do
    if [ -d "$DIR" ]; then
        for JSON_FILE in $DIR/*.json; do
            if [ -f "$JSON_FILE" ]; then
                echo "Sending data from $JSON_FILE to $URL"
                curl -X POST $URL \
                     -H "Content-Type: application/json" \
                     --data-binary "@$JSON_FILE"
                echo "Data from $JSON_FILE sent to $URL"
                echo "Waiting for 30 seconds before sending the next file..."
                sleep 30
            else
                echo "No JSON files found in $DIR"
            fi
        done
    fi
done

echo "All JSON files have been sent."
