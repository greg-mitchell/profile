#!/bin/sh

DEFAULT_BRANCH_NAME=$(~/scripts/git-default-branch.sh)
CURR_BRANCH=$(git branch --show-current)
git checkout "$DEFAULT_BRANCH_NAME"
git pull
git branch -D "$CURR_BRANCH"
