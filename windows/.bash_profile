#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091

set -euo pipefail

source "$HOME"/.bash_common

# Set aliases, functions, and variables
set_aliases
set_functions
set_variables

export PYTHONUTF8=1

# Required for symlinks to work in Git Bash
# Also requires Developer Mode to be enabled or the terminal run as an administrator
# From https://stackoverflow.com/a/40914277/2445901
# See https://cygwin.com/cygwin-ug-net/using-cygwinenv.html for explanation
if [ "$(uname --operating-system)" = "Msys" ]; then
  export MSYS=winsymlinks:nativestrict
fi

# Allow local overrides of other programs
export PATH=$HOME/.local/bin:$PATH

# Set custom prompt last so failure is more obvious
set_prompt

set +euo pipefail
