#!/bin/bash
###
 # @Author: xiongsheng
 # @Date: 2018-07-07 02:37:18
 # @LastEditors: xiongsheng
 # @LastEditTime: 2021-12-19 19:52:39
 # @Description: 
### 
if [ $# -lt  1 ]; then
    echo "$0 <commit message>"
    exit 1
fi
msg="$1"

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"
# Build the project.
hugo # if using a theme, replace with `hugo -t <YOURTHEME>`
# Go To Public folder
cd public
# Add changes to git.
git add .
# Commit changes.
git commit -m "$msg"
# Push source and build repos.
git push origin master
# Come Back up to the Project Root
cd ..
git add public
git commit -m "$msg"
if [ $? -ne 0 ]; then
    echo "Commit failed"
    exit 1
fi
git push origin master
if [ $? -ne 0 ]; then
    echo "Push failed"
fi