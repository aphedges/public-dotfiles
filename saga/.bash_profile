#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091

# Use local copy of Bash as the shell
LOCAL_BASH_PATH=$HOME/.local/bin/bash
if [[ -f "$LOCAL_BASH_PATH" ]] ; then
  # shellcheck disable=SC2016
  LOCAL_BASH_VERSION=$($LOCAL_BASH_PATH -c 'echo $BASH_VERSION')
  export LOCAL_BASH_VERSION
  if [ "$BASH_VERSION" != "$LOCAL_BASH_VERSION" ]; then
    export DISABLE_MOTD=1
    exec $LOCAL_BASH_PATH -l
  else
    export DISABLE_MOTD=
    export SHELL=$BASH
  fi
fi

# Do remaining setup
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi
