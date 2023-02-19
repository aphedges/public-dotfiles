#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091

set -euo pipefail

source "$HOME"/.bash_common

# Set aliases, functions, and variables
set_aliases
set_functions
set_variables

# Initialize programs
initialize_homebrew
initialize_python
initialize_node
initialize_direnv
initialize_trash

# For adding `pycharm`, `idea`, etc. to terminal
JETBRAINS_HOME="$HOME/.jetbrains_scripts"
if [[ -d "$JETBRAINS_HOME" ]] ; then
  export PATH="$JETBRAINS_HOME:$PATH"
fi
unset JETBRAINS_HOME

# For Rust
RUST_HOME="$HOME/.cargo/env"
if [[ -f "$RUST_HOME" ]] ; then
  source "$RUST_HOME"
fi

# Allow local overrides of other programs
export PATH=$HOME/.local/bin:$HOME/bin:$PATH

# Set custom prompt last so failure is more obvious
set_prompt

set +euo pipefail
