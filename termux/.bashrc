#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091

set -euo pipefail

source "$HOME"/.bash_common

# Set aliases, functions, and variables
set_aliases
set_functions
set_variables

# Allow local overrides of other programs
export PATH=$HOME/.local/bin:$PATH

# Load cached $OLDPWD from file
load_oldpwd

set_prompt

set +euo pipefail
