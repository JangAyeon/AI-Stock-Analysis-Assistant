#!/bin/bash

# Fetch and prune remote branches
git checkout main
git fetch --prune
git pull
# Get list of all remote branches
remote_branches=$(git branch -r)

# Initialize an empty array to hold branches to be deleted
branches_to_delete=()

# Loop over all local branches
for branch in $(git branch --format="%(refname:short)"); do
    # If local branch is not in remote branches
    if [[ $remote_branches != *"$branch"* ]]; then
        # Add branch to the list of branches to be deleted
        branches_to_delete+=($branch)
    fi
done

# If there are branches to be deleted
if [ ${#branches_to_delete[@]} -ne 0 ]; then
    echo "The following branches do not exist on the remote and will be deleted:"
    for branch in "${branches_to_delete[@]}"; do
        echo $branch
    done

    # Ask user for confirmation
    read -p "Do you want to delete these branches? (y/n) " -n 1 -r
    echo    # move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        # If user confirms, delete the branches
        for branch in "${branches_to_delete[@]}"; do
            git branch -d $branch
        done
    fi
else
    echo "No local branches to delete."
fi