#!/bin/sh

# ci_post_clone.sh
# This script runs automatically in Xcode Cloud after the repository is cloned.

set -e

# Use the Xcode Cloud build number as the project's build number.
if [ -z "$CI_BUILD_NUMBER" ]; then
  echo "CI_BUILD_NUMBER not set, skipping build number update."
  exit 0
fi

echo "Updating CURRENT_PROJECT_VERSION to $CI_BUILD_NUMBER..."

# Navigate to the directory containing the Xcode project
cd "$CI_PRIMARY_REPOSITORY_PATH"

# Update all instances of CURRENT_PROJECT_VERSION in the project file
# Ensure the .xcodeproj name matches exactly
sed -i '' "s/CURRENT_PROJECT_VERSION = .*;/CURRENT_PROJECT_VERSION = $CI_BUILD_NUMBER;/g" contactformatter.xcodeproj/project.pbxproj

echo "Successfully updated build number to $CI_BUILD_NUMBER"
