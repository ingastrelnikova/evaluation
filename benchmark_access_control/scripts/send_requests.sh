#!/bin/bash

URL="http://localhost:3002/data"

while true; do
    curl $URL
    sleep 15
done
