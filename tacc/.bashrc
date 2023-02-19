#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091

# TACC startup script: ~/.bashrc version 2.1 -- 12/17/2013

# In a parallel mpi job, this file (~/.bashrc) is sourced on every 
# node so it is important that actions here not tax the file system.
# Each nodes' environment during an MPI job has ENVIRONMENT set to
# "BATCH" and the prompt variable PS1 empty.

#################################################################
# Optional Startup Script tracking. Normally DBG_ECHO does nothing
if [ -n "$SHELL_STARTUP_DEBUG" ]; then
  DBG_ECHO "${DBG_INDENT}~/.bashrc{"
fi

############
# SECTION 1
#
# There are three independent and safe ways to modify the standard
# module setup. Below are three ways from the simplest to hardest.
#   a) Use "module save"  (see "module help" for details).
#   b) Place module commands in ~/.modules
#   c) Place module commands in this file inside the if block below.
#
# Note that you should only do one of the above.  You do not want
# to override the inherited module environment by having module
# commands outside of the if block[3].

if [[ -z "$__BASHRC_SOURCED__" && "$ENVIRONMENT" != BATCH ]]; then
  export __BASHRC_SOURCED__=1

  ##################################################################
  # **** PLACE MODULE COMMANDS HERE and ONLY HERE.              ****
  ##################################################################

  module load htop
  module load tacc-singularity
  # module load python_cacher

fi

############
# SECTION 2
#
# Please set or modify any environment variables inside the if block
# below.  For example, modifying PATH or other path like variables
# (e.g LD_LIBRARY_PATH), the guard variable (__PERSONAL_PATH___) 
# prevents your PATH from having duplicate directories on sub-shells.

if [ -z "$__PERSONAL_PATH__" ]; then
  export __PERSONAL_PATH__=1

  ###################################################################
  # **** PLACE Environment Variables including PATH here.        ****
  ###################################################################

  # export PATH=$HOME/bin:$PATH

fi

##########
# Umask
#
# If you are in a group that wishes to share files you can use 
# "umask". to make your files be group readable.  Placing umask here 
# is the only reliable place for bash and will insure that it is set 
# in all types of bash shells.

# umask 022

###################################
# Optional Startup Script tracking 

if [ -n "$SHELL_STARTUP_DEBUG" ]; then
  DBG_ECHO "${DBG_INDENT}}"
fi


# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# Exit early if rest of file is not needed
# Source: https://unix.stackexchange.com/a/154431
# Test if the prompt var is not set
if [ -z "${PS1:-}" ]; then
  # Prompt var is not set, so this is *not* an interactive shell
  return
fi

#set -euo pipefail

source "$HOME"/.bash_common

# Set aliases, functions, and variables
set_aliases
set_functions
set_variables

# Initialize programs
initialize_slurm
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
