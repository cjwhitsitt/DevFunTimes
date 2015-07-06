set startupMessage to ""
set cleanXcode to false
set gCurrentWorkspace to false

###############################
## Clean and close current workspace
tell application "Xcode"
	if (application "Xcode" is running) and ((active workspace document) is not equal to missing value) then
		set cleanXcode to true
		set startupMessage to "This will
1. Clean the active Xcode workspace
2. Quit Xcode
3. Permanently delete the contents of the Derived Data folder
4. Reset all installed iOS simulators
5. If all of the above worked correctly, reopen the currently active Xcode workspace.

Proceed with the active Xcode workspace as " & name of active workspace document & "?"
	else
		set startupMessage to "This will
1. *Clean the active Xcode workspace
2. *Quit Xcode
3. Permanently delete the contents of the Derived Data folder
4. Reset all installed iOS simulators
5. *If all of the above worked correctly, reopen the currently active Xcode workspace.

* Since you don't have an open Xcode workspace, the Xcode-specific steps cannot be performed. Running this script now may be sufficient but if you have issues, you may want to run this again with your workspace open.

Proceed without cleaning your Xcode workspace?"
	end if
end tell

display dialog startupMessage buttons {"Cancel", "Continue"} default button 2

if cleanXcode then
	tell application "Xcode"
		
		set gCurrentWorkspace to active workspace document
		tell gCurrentWorkspace
			clean
		end tell
		
		display dialog "Please check the top status view and click Continue when it says
\"Cleaning {project name}: Succeeded\".

This step is necessary because there's currently a bug with Xcode where it tells the system that cleaning has finished when it really hasn't. #thanksApple" buttons {"Cancel", "Continue"}
	end tell
end if

tell application "Xcode"
	quit
end tell

###############################
## Permanently delete Derived Data folder
do shell script "
#Save the starting dir
startingDir=$PWD

#Go to the derivedData
cd ~/Library/Developer/Xcode/DerivedData

#Sometimes, 1 file remains, so loop until no files remain
numRemainingFiles=1
while [ $numRemainingFiles -gt 0 ]; do
    #Delete the files, recursively
    rm -rf *

    #Update file count
    numRemainingFiles=`ls | wc -l`
done

echo Done

#Go back to starting dir
cd $startingDir
"
if result is not "Done" then error result

###############################
## Reset simulators
set devices to do shell script "xcrun simctl list"
set the text item delimiters to return
set uuids to ""

repeat with nextLine in (text items of devices)
	try
		set openPar to offset of "(" in nextLine
		if openPar is 0 then error "No open parenthesis" number 987
		
		set closePar to offset of ")" in nextLine
		if closePar is 0 then error "No close parenthesis" number 987
		
		set substring to text (openPar + 1) thru (closePar - 1) of nextLine
		if substring starts with "com." then
			error "Expected uuid is actually a bundle id" number 987
		else
			set periodOffset to (offset of "." in substring)
			if periodOffset is equal to 2 then error "Expected uuid is actually an iOS version" number 987
		end if
		
		set command to "xcrun simctl erase " & substring
		do shell script command
		if result is not "" then
			set msg to "Unexpected result from command \"" & command & "\"

" & result & "

Continue?"
			display dialog msg buttons {"End Now", "Continue"}
			if button returned is "End Now" then error msg
		else
			#uncomment for debugging
			#set uuids to uuids & command & "
			#"
		end if
	on error msg number n from f to t partial result p
		if n is equal to 987 then
		else if (offset of "The file doesn�t exist." in msg) is not equal to 0 then # This error should contain a smart quote as of Xcode 6.4
		else
			error msg number n from f to t partial result p
		end if
	end try
end repeat

if gCurrentWorkspace is not false then open gCurrentWorkspace
return "Done"