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

#set -euo pipefail

source "$HOME"/.bash_common

# Set aliases, functions, and variables
set_aliases
set_functions
set_variables

# Set default Singular cache directory to directory with more space
export SINGULARITY_CACHEDIR=/redacted/.singularity/

# Load programs from Spack
if [[ $SHLVL -eq 1 ]]; then
  module purge
  module load gcc/12.3.0
  SPACK_PACKAGES=(
    curl
    diffutils
    file
    findutils
    gawk
    git
    gmake
    gzip
    htop
    libxml2
    man-db
    openjdk
    openssh
    openssl
    rsync
    screen
    sed
    tar
    unzip
    util-linux
    vim
    which
    zip
  )
  module load "${SPACK_PACKAGES[@]}"
fi

# Initialize programs
# Do not attempt to initialize Slurm on data transfer nodes
if [[ ${HOSTNAME:-} != hpc-transfer@(1|2).hpc.usc.edu ]]; then
  initialize_slurm || true
fi
initialize_pyenv
initialize_python

# Allow local overrides of other programs
export PATH=$HOME/.local/bin:$HOME/bin:$PATH
# direnv is installed in `~/.local/bin/` instead of with Spack,
# so initialization after the `$PATH` change is needed
initialize_direnv

# Load cached $OLDPWD from file
load_oldpwd

# Set custom prompt last so failure is more obvious
set_prompt

#set +euo pipefail
