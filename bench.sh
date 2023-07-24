#!/bin/bash

# Usage example: ./bench.sh 0.9.0
version="$1"
# Check if the version was provided
if [ -z "$version" ]; then
    echo "Please provide the version as the first command-line argument."
    exit 1
fi

## Prepare env
rm -rf exhaust metadata remote-raw
mkdir -p benchmark
find ./pics -type f -exec basename {} \; | xargs -I {} echo "curl -s -H 'User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:98.0) Gecko/20100101 Firefox/98.0' http://localhost:3333/{}" > curl.sh
chmod +x curl.sh

## Build Start WebP Server Go
cd ../webp_server_go && git checkout $version && make && cd ../webp_bench && cp ../webp_server_go/builds/webp-server-linux-amd64 ./
LD_PRLOAD=/usr/lib64/libjemalloc.so.2 ./webp-server-linux-amd64 &

# Step 2: Find the PID of the server process
server_pid=$(ps -aux | grep "webp-server-linux-amd64" | grep -v grep | awk '{print $2}')

# Step 3: Check if the PID was found and execute psrecord if found
if [ -n "$server_pid" ]; then
    # Get the version from the first command-line argument
    psrecord $server_pid --plot "./benchmark/$version.png" &
    # Execute the curl script
    ./curl.sh
else
    echo "Server process not found."
fi

# Kill WebP Server Go and psrecord
kill -9 $server_pid
rm -rf exhaust metadata remote-raw curl.sh