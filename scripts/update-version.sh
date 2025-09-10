#!/bin/bash

# Script to update version tags across the entire redis-operator project
# Usage: ./scripts/update-version.sh <new-version>
# Example: ./scripts/update-version.sh v1.4.0

set -e

if [ $# -eq 0 ]; then
    echo "Error: No version provided"
    echo "Usage: $0 <new-version>"
    echo "Example: $0 v1.4.0"
    exit 1
fi

NEW_VERSION="$1"
NEW_VERSION_NO_V="${NEW_VERSION#v}"  # Remove 'v' prefix for appVersion fields

echo "Updating version to: $NEW_VERSION"

# Function to update file with sed
update_file() {
    local file="$1"
    local pattern="$2"
    local replacement="$3"
    
    if [ -f "$file" ]; then
        echo "Updating $file..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS sed
            sed -i '' "$pattern" "$file"
        else
            # Linux sed
            sed -i "$pattern" "$file"
        fi
    else
        echo "Warning: File $file not found"
    fi
}

# Update Makefile
update_file "Makefile" "s/^VERSION := .*/VERSION := $NEW_VERSION/" 

# Update Helm Chart appVersion
update_file "charts/redisoperator/Chart.yaml" "s/^appVersion: .*/appVersion: $NEW_VERSION_NO_V/"

# Update Helm values image tag
update_file "charts/redisoperator/values.yaml" "s/tag: .*/tag: $NEW_VERSION/"

# Update Kustomize version label
update_file "manifests/kustomize/components/version/kustomization.yaml" "s/app.kubernetes.io\/version: .*/app.kubernetes.io\/version: $NEW_VERSION_NO_V/"

# Update Kustomize image tag
update_file "manifests/kustomize/components/version/kustomization.yaml" "s/newTag: .*/newTag: $NEW_VERSION/"

# Update README.md examples
update_file "README.md" "s/REDIS_OPERATOR_VERSION=.*/REDIS_OPERATOR_VERSION=$NEW_VERSION/"

echo "Version update completed!"
echo ""
echo "Files updated:"
echo "- Makefile"
echo "- charts/redisoperator/Chart.yaml"
echo "- charts/redisoperator/values.yaml"
echo "- manifests/kustomize/components/version/kustomization.yaml"
echo "- README.md"
echo ""
echo "Please review the changes and commit them:"
echo "git add ."
echo "git commit -m \"chore: bump version to $NEW_VERSION\""
echo "git tag $NEW_VERSION"
echo "git push origin master --tags"
