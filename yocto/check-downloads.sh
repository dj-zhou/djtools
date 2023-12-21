#!/bin/bash

# Create an associative array to store package names as keys
declare -A package_versions

# Iterate through the files in the directory
for file in *; do
    # Check if the file is a tarball or gzipped tarball
    if [[ "$file" =~ \.tar\.gz$ ]] || [[ "$file" =~ \.tar\.bz2$ ]]; then
        # Extract the package name by removing the version and extension
        package_name=$(echo "$file" | sed -E 's/[-_][0-9]+\.[0-9]+\.[0-9]+(\.tar\.gz|\.tar\.bz2)?$//')

        # Add the package name to the associative array
        package_versions["$package_name"]=1
    fi
done

# Iterate through the keys in the associative array
for package in "${!package_versions[@]}"; do
    # Count the number of versions for each package
    version_count=$(ls -1 | grep -E "^$package-[0-9]+\.[0-9]+\.[0-9]+(\.tar\.gz|\.tar\.bz2)?$" | wc -l)

    # If there is more than one version, print the package name
    if [ "$version_count" -gt 1 ]; then
        echo "Multiple versions of $package found: $version_count versions"
    fi
done
