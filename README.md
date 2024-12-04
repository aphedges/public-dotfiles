# Alex's public dotfiles

This repository contains a squashed and partially redacted version of my private dotfile repository. I want to be able to share my configuration more easily without needing to give access to potentially sensitive information.

The scripts at the top level are licensed with GPLv3. All remaining files are licensed with CC0, although I would appreciate if I were cited. I will clean up the license situation in the future.

Everything below the following horizontal line is copied from the original README.

---

A repository to store my dotfiles and related configuration from various computers. While this repository will start out simple, I plan to expand it into a useful system to make usage of my systems easier.

## Installation

### `mac`

Configuration and command history from my ISI Mac. To do a basic install:

```bash
git clone git@github.com:aphedges/public-dotfiles.git
cd dotfiles/mac/
git ls-files | grep -v Brewfile | xargs -I % bash -c 'rm "$(realpath -s ~/%)"'
git ls-files | grep -v Brewfile | xargs -I % bash -c 'ln -s "$(realpath -s %)" "$(realpath -s ~/%)"'
cd ../shared/
git ls-files | xargs -I % bash -c 'rm "$(realpath -s ~/%)"'
git ls-files | xargs -I % bash -c 'ln -s "$(realpath -s %)" "$(realpath -s ~/%)"'
```

### `saga`

Configuration and command history from the SAGA cluster. To do a basic install:

```bash
git clone git@github.com:aphedges/public-dotfiles.git
cd dotfiles/saga/
git ls-files | xargs -I % bash -c 'rm "$(realpath -s ~/%)"'
git ls-files | xargs -I % bash -c 'ln -s "$(realpath -s %)" "$(realpath -s ~/%)"'
cd ../shared/
git ls-files | xargs -I % bash -c 'rm "$(realpath -s ~/%)"'
git ls-files | xargs -I % bash -c 'ln -s "$(realpath -s %)" "$(realpath -s ~/%)"'
```

## Bundle dotfiles

This repository contains history files that should not be distributed. To bundle this repository without them:

```bash
git ls-files | grep -v '.*_history' | xargs zip -X dotfiles.zip
```

## Development installation

Use the provided Makefile to install this project by running the following from the project root directory (the same directory as this README). Ensure the `python` in `PATH` is 3.11 before running this command:

```shell
make install
```

If the installation process fails, is interrupted, or for any reason needs to be restarted, run `git clean -xdf` to reset the repository's state.

## Contributing

This project uses various code quality tooling, all of which is automatically installed with the rest of the development requirements.

All checks can be run with `make check`, and some additional automatic changes can be run with `make fix`.
