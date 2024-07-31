#!/bin/bash

URL="http://localhost:3002/data"

for i in {1..200}; do
    curl $URL
    sleep 15
done