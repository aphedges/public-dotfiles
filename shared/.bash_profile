#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091

# Use local copy of Bash as the shell, if it works
LOCAL_BASH_PATH=$HOME/.local/bin/bash
if [[ -f $LOCAL_BASH_PATH ]] && "$LOCAL_BASH_PATH" --version 1>/dev/null 2>&1; then
  # shellcheck disable=SC2016
  LOCAL_BASH_VERSION=$($LOCAL_BASH_PATH -c 'echo $BASH_VERSION')
  export LOCAL_BASH_VERSION
  if [[ $BASH_VERSION != "$LOCAL_BASH_VERSION" ]]; then
    export DISABLE_MOTD=1
    exec $LOCAL_BASH_PATH -l
  else
    export DISABLE_MOTD=
    export SHELL=$BASH
  fi
fi

# Do remaining setup
if [[ -f ~/.bashrc ]]; then
  . ~/.bashrc
fi

# Ensure that the executable that ran the shell is the same one in `PATH`
# Handles cases where local executable doesn't work but is present
#
# `-ef` tests that paths point to same file: Fedora sets `SHELL` to
# `/bin/bash` but only adds `/usr/bin` to `PATH`, and the two `bash` files
# are the same because of merged-usr (`/bin` symlinked to `/usr/bin`)
if ! [[ $SHELL -ef $(which "$(basename "$SHELL")") ]]; then
  TEMP_DIR=$(mktemp --directory)
  ln -s "$SHELL" "$TEMP_DIR"/bash
  export PATH=$TEMP_DIR:$PATH
fi
