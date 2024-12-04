#!/usr/bin/env bash

set -euo pipefail

if [[ -f /etc/os-release ]] && grep -q 'CentOS Linux 7' /etc/os-release; then
  CPPFLAGS=$(pkg-config --cflags openssl11)
  LDFLAGS=$(pkg-config --libs-only-L openssl11)

  export CPPFLAGS
  export LDFLAGS
fi

set +euo pipefail
