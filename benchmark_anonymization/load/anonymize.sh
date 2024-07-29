#!/bin/bash

JSON_DIR="json_data"
URL="http://localhost:8080/anonymize/patients"

if [ ! -d "$JSON_DIR" ]; then
    echo "Directory $JSON_DIR does not exist."
    exit 1
fi

for JSON_FILE in $JSON_DIR/*.json; do
    if [ -f "$JSON_FILE" ]; then
        echo "Sending data from $JSON_FILE to $URL"
        curl -X POST $URL \
             -H "Content-Type: application/json" \
             --data-binary "@$JSON_FILE"
        echo "Data from $JSON_FILE sent to $URL"
        echo "Waiting for 30 seconds before sending the next file..."
        sleep 30
    else
        echo "No JSON files found in $JSON_DIR"
        exit 1
    fi
done
