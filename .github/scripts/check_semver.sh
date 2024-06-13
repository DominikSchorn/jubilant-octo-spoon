#!/bin/bash

# SemVer regex pattern for standard version strings
SEMVER_REGEX='ref=[^"]+"'
# Regex patterns for whitelisted versions
WHITELIST_REGEX="ref=(incident|hotfix).*"

# Function to check if a version string is SemVer compliant
is_semver_compliant() {
    local version=$1
    if [[ $version =~ ^ref=v([0-9]+)\.([0-9]+)\.([0-9]+)\"$ ]]; then
        return 0
    else
        return 1
    fi
}

# Get the list of changed lines
changed_lines=$(git diff -U0 HEAD~1 HEAD | grep '^[+]' | sed 's/^+//')

# Check each changed line for SemVer compliance
non_compliant_versions=()
while IFS= read -r line; do
    if [[ $line =~ $WHITELIST_REGEX ]]; then
      continue 
    # Check for standard SemVer strings
    elif [[ $line =~ $SEMVER_REGEX ]]; then
        version=${BASH_REMATCH[0]}
        if ! is_semver_compliant "$version"; then
            non_compliant_versions+=("$version")
        fi
    fi
done <<< "$changed_lines"

if [ ${#non_compliant_versions[@]} -ne 0 ]; then
    echo "Found non-compliant SemVer strings:"
    for version in "${non_compliant_versions[@]}"; do
        echo "$version"
    done
    exit 1
else
    echo "All versions are SemVer compliant."
fi

