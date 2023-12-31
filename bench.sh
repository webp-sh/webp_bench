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
find ./pics -type f -exec basename {} \; | xargs -I {} echo "curl -s -H 'Accept: image/webp' http://localhost:3333/{}" > curl.sh
chmod +x curl.sh

## Build Start WebP Server Go
cd ../webp_server_go && git checkout $version && make && cd ../webp_bench && cp ../webp_server_go/builds/webp-server-linux-amd64 ./
LD_PRLOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2 ./webp-server-linux-amd64 &

# Step 2: Find the PID of the server process
server_pid=$(ps -aux | grep "webp-server-linux-amd64" | grep -v grep | awk '{print $2}')

# Step 3: Check if the PID was found and execute psrecord if found
if [ -n "$server_pid" ]; then
    # Get the version from the first command-line argument
    psrecord $server_pid --plot "./benchmark/$version.png" &
    # Execute the curl script
    ./curl.sh
    # Get server_pid RAM usage and running time
    # 0.9.0 1200 2:01
    # version RAM(MB) Time(MM:SS)
    echo "$version $(($(ps -p $server_pid -o rss=) / 1024)) $(ps -p $server_pid -o etime=)" >> ./benchmark/data.txt
else
    echo "Server process not found."
fi

# Kill WebP Server Go and psrecord
kill -9 $server_pid
rm -rf exhaust metadata remote-raw curl.sh