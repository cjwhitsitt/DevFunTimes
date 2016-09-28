#!/bin/bash

# Merge issue branch
# This script will merge the current branch into develop with the --no-ff flag
# Created by Jay Whitsitt
# Use as you'd like... It's a git script

#get current branch name
branch=$(git branch | grep \* | cut -d ' ' -f2)

#change to develop
git checkout develop

#merge
result=$(git merge --no-ff $branch)
echo "$result"
