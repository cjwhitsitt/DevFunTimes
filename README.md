# scripts
This repo contains scripts I've made to streamline things.

### [Xcode/](https://github.com/cjwhitsitt/scripts/tree/master/Xcode)
#### [Super Clean.applescript](https://github.com/cjwhitsitt/scripts/blob/master/Xcode/Super%20Clean.applescript)
This AppleScript will 

1. \*Clean the active Xcode workspace
2. \*Quit Xcode
3. Permanently delete the contents of the Derived Data folder
4. Reset all installed iOS simulators
5. \*If all of the above worked correctly, reopen the currently active Xcode workspace.

\* These require that the script be ran with an Xcode workspace document open. The Xcode window does not have to be the top-most window though, just open. If a workspace document is not open when this is ran, these steps will be skipped.

I have put this in my `~/Library/Scripts/Applications/Xcode` folder and [enabled the AppleScript menu](http://thepoch.com/2012/enable-the-script-menu-in-mac-os-xs-menu-bar.html). That allows for quick access to the script when I need it.
