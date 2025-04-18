#!/bin/sh

REPO_ROOT=$(git rev-parse --show-toplevel)
# This script caches the remote default branch name in a file in the .git dir.
DEFAULT_BRANCH_FILE="$REPO_ROOT/.git/REMOTE_DEFAULT_BRANCH"
# If the branch name cache exists, DEFAULT_BRANCH_NAME will store the name.
# Otherwise, it will be blank.
DEFAULT_BRANCH_NAME=$([ -f $DEFAULT_BRANCH_FILE ] && cat $DEFAULT_BRANCH_FILE)

# If the branch name is empty:
if [ -s $DEFAULT_BRANCH_NAME ]; then
    # We have not previously found or saved the remote default branch name.
    # Get the name of the remote repo (typically origin)
    REMOTE_REPO_NAME=$(git remote)
    # git remote show will print all branches, starting with some metadata.
    # This includes the default branch.
    DEFAULT_BRANCH_NAME=$(git remote show $REMOTE_REPO_NAME | grep 'HEAD branch' | cut -d' ' -f5)
    # Cache in .git
    echo "${DEFAULT_BRANCH_NAME}" > $DEFAULT_BRANCH_FILE
fi

# script output: the branch name
echo "${DEFAULT_BRANCH_NAME}"
