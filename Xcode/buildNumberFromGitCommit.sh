#!/bin/bash

# update_build_number.sh
# Usage: `update_build_number.sh [branch]`
# Run this script after the 'Copy Bundle Resources' build phase
# Ref: http://tgoode.com/2014/06/05/sensible-way-increment-bundle-version-cfbundleversion-xcode/

# I've added these pieces to the original script (link above):
#	1. buildNumber will be total number of commits on given branch, not just commits on master
#	2. If no branch is given, defaults to HEAD, which should be current branch
#	3. For any builds not created using the Release configuration, buildNumber is prepended with "d" (for debug or development)
#		- This will make it easier to figure out which builds are meant to be dev and release
#	4. In some cases, the dSYM may not be created. If it's not, skip the last step

# set branch to HEAD if none given
if [ -z "$branch" ]; then
branch="HEAD"
fi;

# set build number
buildNumber=$(git rev-list "$branch" --count)
if [ ${CONFIGURATION} != "Release" ]; then
buildNumber="d$buildNumber"
fi;

# do the things
echo "Updating build number to $buildNumber using branch '$branch'."
command="Set :CFBundleVersion $buildNumber"

echo "Setting value for .app package"
/usr/libexec/PlistBuddy -c "$command" "${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"

filepath="${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}.dSYM/Contents/Info.plist"
if [ -f "$filepath" ]; then
echo "Setting value for .app.dSYM package"
/usr/libexec/PlistBuddy -c "$command" "$filepath"
fi;
