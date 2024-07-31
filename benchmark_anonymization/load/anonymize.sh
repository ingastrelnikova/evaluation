#!/bin/bash

# Get the directory with data
SCRIPT_DIR=$(dirname "$0")
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
                curl -X POST $URL \
                     -H "Content-Type: application/json" \
                     --data-binary "@$JSON_FILE"
                sleep 30
            else
                echo "No JSON files found in $DIR"
            fi
        done
    fi
done

echo "All sent."
