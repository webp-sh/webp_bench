#!/bin/bash
VERSIONS=()

# 0.8.0 ~ 0.8.4
for i in {0..4}; do
    version="0.8.$i"
    VERSIONS+=("$version")
done

# 0.9.0 ~ 0.9.10
for i in {0..10}; do
    version="0.9.$i"
    VERSIONS+=("$version")
done

# print all versions
echo "All versions: ${VERSIONS[@]}"

for version in "${VERSIONS[@]}"; do
    echo "Running ./bench.sh version $version..."
    ./bench.sh "$version"
done