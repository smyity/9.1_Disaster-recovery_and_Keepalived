#!/bin/bash

# check port
echo "check port 80"

if curl "http://localhost:80" > /dev/null; then
    echo "port 80 available"
else
    echo "port 80 unavailable"
    exit 1
fi

# check file index.html
echo "check file index.html"

if [ -f "/var/www/html/index.html" ]; then
    echo "file exist"
else
    echo "file not exist"
    exit 2
fi

exit 0

