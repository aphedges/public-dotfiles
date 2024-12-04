#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091

# Condition from https://stackoverflow.com/a/85903/2445901
if [[ $(type -t save_oldpwd) == function ]]; then
  save_oldpwd
fi
