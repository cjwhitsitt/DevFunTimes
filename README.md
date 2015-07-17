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

#### [Auto-Increment Build Number](https://github.com/cjwhitsitt/scripts/blob/master/Xcode/buildNumberFromGitCommit.sh)
This script can be run during the build phase of an Xcode project to automatically generate a build number. The number will be equal to the number of git commits in the current branch.

Many people seem to base the number off of number of commits in the master branch, but I did it this way for a couple reasons:

- You don't always only distribute builds using the Release configuration. For example, release candidates, demo builds, etc.
- Crash logs that include the build number will correspond to a specific commit (or rather code between two commits in the case of uncommitted changes).

This script should be added to a build phase anytime after the Copy Bundle Resources phase. To be safe, I usually make this the last phase.

**Note**: To avoid distributing builds that are one number lower than what you expect, be sure to commit any changes prior to distributing a build.
