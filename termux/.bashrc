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

# Set custom prompt last so failure is more obvious
# Keep original PS1 to limit length on the smaller phone screen
# This should be remove later once I add smarter PS1 logic
OLD_PS1=$PS1
set_prompt
PS1=$OLD_PS1

set +euo pipefail
