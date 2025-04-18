#!/bin/sh

# Relies on this script being a sibling of git-default-branch.sh
DEFAULT_BRANCH_NAME=$(~/scripts/git-default-branch.sh)
CURR_BRANCH=$(git branch --show-current)
git checkout $DEFAULT_BRANCH_NAME
git pull
git checkout $CURR_BRANCH
git rebase $DEFAULT_BRANCH_NAME
