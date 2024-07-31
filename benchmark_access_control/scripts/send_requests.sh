#!/bin/bash

URL="http://research-service:3002/data"

while true; do
    curl -s $URL
    sleep 15
done