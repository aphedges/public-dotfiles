#!/usr/bin/env bash

set -euo pipefail

# Script to install [GNU Bash](https://www.gnu.org/software/bash/)

if [[ "$#" -lt 1 ]] || [[ "$#" -gt 2 ]] || [[ "$1" = "--help" ]]; then
  echo "usage: bash $0 [--help] NEW_VERSION [INSTALL_DIR]" >&2
  echo "This script automates installation of GNU Bash from source." >&2
  echo 'NEW_VERSION should be the new Bash version to install, e.g., "5.2.15".' >&2
  # shellcheck disable=SC2016
  echo 'INSTALL_DIR is the directory Bash will be installed to. It defaults to "$HOME/.local/".' >&2
  exit 1
fi

NEW_VERSION=$1
if [[ -n "${2:-}" ]]; then
  INSTALL_DIR=$2
else
  INSTALL_DIR=$HOME/.local/
fi
INSTALL_DIR=$(realpath "$INSTALL_DIR")

# Add GNU keys if required key is not present
if ! command -v gpg 1>/dev/null 2>&1; then
  echo "'gpg' (GnuPG) not found. Install before re-running this script." >&2
  exit 2
fi
if ! gpg --list-keys 'Chet Ramey'; then
  gpg --import <(curl -s https://ftp.gnu.org/gnu/gnu-keyring.gpg)
fi

# Do all work in a temporary directory for easier cleanup
TEMP_DIR=$(mktemp --directory)
pushd "$TEMP_DIR"

# Download and verify source file
wget https://ftpmirror.gnu.org/bash/bash-"$NEW_VERSION".tar.gz
wget https://ftpmirror.gnu.org/bash/bash-"$NEW_VERSION".tar.gz.sig
gpg --verify bash-"$NEW_VERSION".tar.gz.sig bash-"$NEW_VERSION".tar.gz

# Extract, build, test, and install Bash
tar xvf bash-"$NEW_VERSION".tar.gz
cd bash-"$NEW_VERSION"/
./configure --prefix="$INSTALL_DIR"
make
PS4='+ ' make test
make install

popd
rm -rf "$TEMP_DIR"
