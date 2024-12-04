#!/usr/bin/env bash

set -euo pipefail

# Script to snapshot Git repos

# Here is an example `crontab` to run the script automatically on macOS:
# ```
# SHELL=/usr/local/bin/bash
# @hourly /usr/local/bin/bash $HOME/dotfiles/snapshot_git.sh $HOME/notes/ &>>$HOME/.cache/note_snapshot_log.txt
# ```

PAUSE_FILE=.gitpause

if [[ "$#" -gt 1 ]] || [[ ${1:-} = --help ]]; then
  {
    echo "usage: bash $0 [--help] [GIT_REPO]"
    echo
    echo 'This script automatically creates a snapshot of a Git repository.'
    echo
    echo 'It was created to track the history of note files without user intervention.'
    echo 'The script should be set up as a cron job, systemd service, etc. to be run regularly.'
    echo
    echo "\`GIT_REPO\` is the directory of the Git repository to snapshot."
    echo 'If not provided, the current working directory will be used instead.'
    echo
    echo "If the working directory contains a file named \`$PAUSE_FILE\`, "
    echo 'then the snapshotting will not run until the file is removed.'
  } >&2
  exit 1
fi

if [[ -n ${1:-} ]]; then
  GIT_REPO=$1
else
  GIT_REPO=$PWD
fi

cd "$GIT_REPO"

if [[ -f $PAUSE_FILE ]]; then
  echo "\`$PAUSE_FILE\` found, skipping snapshot" >&2
  exit 2
fi

git add .
git commit -m "Snapshot files at $(date +'%Y-%m-%d %H:%M:%S %Z') on $(hostname)" || true
git push
