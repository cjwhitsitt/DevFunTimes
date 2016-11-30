set logging to false

set cleanXcode to false
local currentWorkspace
local workspaceFile

set reopenXcodeOption to "Reopen Xcode"

###############################
## Clean and close current workspace
set startupMessage to ""
if (application "Xcode" is running) then
	tell application "Xcode"
		set currentWorkspace to active workspace document
		if (currentWorkspace is not equal to missing value) then
			set cleanXcode to true
			set workspaceFile to file of currentWorkspace
			set startupMessage to "This will
1. Clean the active Xcode workspace
2. Quit Xcode
3. Permanently delete the contents of the Derived Data folder
4. Reset all installed iOS simulators
5. If you clicked the \"" & reopenXcodeOption & "\" button and all of the above worked correctly, reopen the currently active Xcode workspace.

Proceed with the active Xcode workspace as " & name of currentWorkspace & "?"
		end if
	end tell
end if

if startupMessage is equal to "" then
	set startupMessage to "This will
1. *Clean the active Xcode workspace
2. *Quit Xcode
3. Permanently delete the contents of the Derived Data folder
4. Reset all installed iOS simulators
5. *If you clicked the \"" & reopenXcodeOption & "\" button and all of the above worked correctly, reopen the currently active Xcode workspace.

* Since you don't have an open Xcode workspace, the Xcode-specific steps cannot be performed. Running this script now may be sufficient but if you have issues, you may want to run this again with your workspace open.

Proceed without cleaning your Xcode workspace?"
end if

local reopenOption
tell application "System Events"
	display dialog startupMessage buttons {"Cancel", "Don't Reopen Xcode", reopenXcodeOption} default button 3
	set reopenOption to button returned of result
end tell

if cleanXcode then
	tell application "Xcode"
		tell currentWorkspace
			-- Clean now immediately returns a dictionary
			set schemeResult to clean
			
			-- include timeout in case it takes entirely too long
			set timeoutSeconds to 240
			repeat timeoutSeconds times
				if completed of schemeResult is true then
					exit repeat
				end if
				delay 1
			end repeat
			
			if completed of schemeResult is false then
				error "Clean timed out after " & timeoutSeconds & " seconds"
			end if
		end tell
	end tell
end if

tell application "System Events"
	display dialog "Closing Xcode now"
end tell

###############################
## Permanently delete Derived Data folder
tell application "Xcode"
	quit
end tell

do shell script "
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
"
if result is not "Done" then error result

###############################
## Reset simulators
if (application "iOS Simulator" is running) then
	tell application "iOS Simulator"
		quit
	end tell
else if (application "Simulator" is running) then
	tell application "Simulator"
		quit
	end tell
end if

set devices to do shell script "xcrun simctl list"
set the text item delimiters to return
set uuids to ""
set inDevices to false

repeat with nextLine in (text items of devices)
	try
		if logging then
			log "New line: " & nextLine
		end if
		
		if not ((offset of "==" in nextLine) is 0) then # if starting a section
			if ((offset of "== Devices ==" in nextLine) is 0) then # and the section is Devices
				set inDevices to false
			else # and the section is not Devices
				set inDevices to true
			end if
		end if
		
		if not inDevices then
			error "Not in devices" number 987
		end if
		
		-- find the device id in the line
		set idLength to 37 -- if device id length changes, update this value
		set searchString to nextLine -- update with next substring to search for parenthesis pairs
		local openPar, closePar
		repeat
			set openPar to offset of "(" in searchString
			if openPar is 0 then error "No open parenthesis" number 987
			
			set closePar to offset of ")" in searchString
			if closePar is 0 then error "No close parenthesis" number 987
			
			if logging then
				log "Searching: " & text closePar thru openPar of searchString
			end if
			
			if (closePar - openPar) is idLength then
				if logging then
					log "Found id"
				end if
				exit repeat
			end if
			
			if logging then
				log "Didn't find id - moving down nextLine"
			end if
			
			set currentLength to length of searchString
			set searchString to text (closePar + 1) thru currentLength of searchString
		end repeat
		
		set substring to text (openPar + 1) thru (closePar - 1) of searchString -- +1 and -1 to remove the outer parenthesis
		if logging then
			log substring
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
		else if (offset of "The file doesn’t exist." in msg) is not equal to 0 then # This error should contain a smart quote as of Xcode 6.4
		else
			error msg number n from f to t partial result p
		end if
	end try
end repeat

# Reopen Xcode if necessary
if cleanXcode and reopenOption is equal to reopenXcodeOption then
	tell application "Finder"
		open workspaceFile
	end tell
else
	display dialog "Super Clean is finished!"
end if

return "Done"
