#!/bin/bash

# merge_settings_plist.sh

# This script will take an array of PreferenceSpecifiers dictionaries and add it to the target's Settings.bundle/Root.plist. 
# 1. Add this to your target's build settings in a Run Script Phase
# 2. Add an array of dictionaries that can be copied within the PreferenceSpecifiers array of your settings plist
# 3. Change the debugPlistName var to the path where your plist exists within your Xcode project

# do the things
debugPlistName="PathFromProjectRoot.plist"
targetPlistName="Settings.bundle/Root.plist"
echo "Merging $debugPlistName into $targetPlistName"
command="Merge $debugPlistName :PreferenceSpecifiers"
/usr/libexec/PlistBuddy -c "$command" "${CODESIGNING_FOLDER_PATH}/$targetPlistName"
