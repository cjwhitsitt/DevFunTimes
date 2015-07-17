#!/bin/bash

# update_build_number.sh
# Usage: `update_build_number.sh [branch]`
# Run this script after the 'Copy Bundle Resources' build phase
# Ref: http://tgoode.com/2014/06/05/sensible-way-increment-bundle-version-cfbundleversion-xcode/

# I've added these pieces to the original script (link above):
#	1. buildNumber will be total number of commits, not just commits on master
#	2. For any builds not created using the Release configuration, buildNumber is prepended with "d" (for debug or development)
#		- This will make it easier to figure out which builds are meant to be dev and release

buildNumber=$(git rev-list HEAD --count)

if [ ${CONFIGURATION} != "Release" ]; then
buildNumber="d$buildNumber"
fi;

echo "Updating build number to $buildNumber using branch '$branch'."
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}.dSYM/Contents/Info.plist"
