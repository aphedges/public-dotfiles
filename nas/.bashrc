#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091

# Source global definitions
if [[ -f /etc/bashrc ]]; then
  . /etc/bashrc
fi

# Exit early if rest of file is not needed
# Source: https://unix.stackexchange.com/a/154431
# Test if the prompt var is not set
if [[ -z ${PS1:-} ]]; then
  # Prompt var is not set, so this is *not* an interactive shell
  return
fi

set -euo pipefail

source "$HOME"/.bash_common

# Set aliases, functions, and variables
set_aliases
set_functions
set_variables

# Initialize programs
initialize_direnv

# Allow local overrides of other programs
export PATH=$HOME/.local/bin:$HOME/bin:$PATH

# Load cached $OLDPWD from file
load_oldpwd

# Set custom prompt last so failure is more obvious
set_prompt

set +euo pipefail
