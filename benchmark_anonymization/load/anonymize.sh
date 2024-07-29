#!/bin/bash

JSON_DIR="json_data"
JSON_FILE="$JSON_DIR/patients_10000_10.json"
URL="http://localhost:8083/anonymize/patients"

if [ ! -f "$JSON_FILE" ]; then
    echo "File $JSON_FILE does not exist."
    exit 1
fi

curl -X POST $URL \
     -H "Content-Type: application/json" \
     --data-binary "@$JSON_FILE"

echo "Data from $JSON_FILE sent to $URL"
