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

# Get the list of changed files
changed_files=$(git diff --name-only HEAD~1 HEAD)

# Check each changed file for SemVer compliance
non_compliant_versions=()
for file in $changed_files; do
    # Get the changed lines for each file
    changed_lines=$(git diff HEAD~1 HEAD -- "$file")
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
    done <<< "$changed_lines"
done

if [ ${#non_compliant_versions[@]} -ne 0 ]; then
    echo "Found non-compliant SemVer strings:"
    for version in "${non_compliant_versions[@]}"; do
        echo "$version"
    done
    exit 1
else
    echo "All versions are SemVer compliant."
fi
