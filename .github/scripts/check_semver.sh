#!/bin/bash

# SemVer regex pattern
SEMVER_REGEX="ref=(.*)"
WHITELIST_REGEX="ref=(incident|hotfix)-v([0-9a-zA-Z\.\-]+)"

# Function to check if a version string is SemVer compliant
is_semver_compliant() {
    local version=$1
    if [[ $version =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
        return 0
    else
        return 1
    fi
}

# Check each changed line for SemVer compliance
non_compliant_versions=()
while IFS= read -r line; do
    if [[ $line =~ $SEMVER_REGEX ]]; then
        version=${BASH_REMATCH[1]}
        if ! is_semver_compliant "$version"; then
            non_compliant_versions+=("$version")
        fi
    elif [[ $line =~ $WHITELIST_REGEX ]]; then
        # Versions with 'incident' or 'hotfix' prefix are whitelisted
        continue
    fi
done <<< "$CHANGED_LINES"

if [ ${#non_compliant_versions[@]} -ne 0 ]; then
    echo "Found non-compliant SemVer strings:"
    for version in "${non_compliant_versions[@]}"; do
        echo "$version"
    done
    exit 1
else
    echo "All versions are SemVer compliant."
fi
