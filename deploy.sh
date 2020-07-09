#!/bin/sh

# If a command fails then the deploy stops
set -e

printf "\033[0;32mDeploying updates to GitHub...\033[0m\n"

# Go To Public folder
cd public

# Fetch the new pushed changes
git fetch

# Checkout to master branch
git checkout master

# Reset master to the upstream level
git reset --hard origin/master

# Get back to root folder
cd ..

# Build the project.
hugo # if using a theme, replace with `hugo -t <YOURTHEME>`

# Go To Public folder
cd public

# Add changes to git.
git add .

# Commit changes.
msg="rebuilding site $(date)"
if [ -n "$*" ]; then
	msg="$*"
fi
git commit -m "$msg"

# Push source and build repos.
git push origin master

# Go back to project root
cd ..

# Fetch the new pushed changes
git fetch

# Checkout to master branch
git checkout master

# Reset master to the upstream level
git reset --hard origin/master
