"""Script to store pyenv versions and pyenv-virtualenv environments in JSON format as backup."""

import argparse
import json
from pathlib import Path
import re
import subprocess
from typing import Tuple


def run(*args: str) -> str:
    """Runs an external command to obtain its output.

    Args:
        *args: Components of the command to run.

    Returns:
        Command output.
    """
    return subprocess.check_output(args, encoding="utf-8", stderr=subprocess.DEVNULL).strip()


def version_sort_key(version_name: str) -> Tuple[Tuple[int, ...], str]:
    """Generates key for sorting pyenv versions by Python version.

    Args:
        version_name: Name of pyenv version.

    Returns:
        Python version tuple (if extractable, a large tuple otherwise) and version name.
    """
    match = re.fullmatch(r"(\d+).(\d+).(\d+)/?.*", version_name)
    if match:
        version = tuple(int(i) for i in match.groups())
    else:
        version = (10 ** 12,)  # Safe to assume no "Python One Trillion" release any time soon
    return version, version_name


def main() -> None:
    """Stores contents of pyenv."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--output-file",
        default=Path("virtualenvs.json"),
        type=Path,
        help="File to save pyenv contents to.",
    )
    args = parser.parse_args()

    global_version = run("pyenv", "global")

    versions = run("pyenv", "versions", "--bare", "--skip-aliases").split("\n")
    # Sort versions as tuples, e.g. "3.6.13" -> (3, 6, 13)
    versions = sorted((ver for ver in versions if "/envs/" not in ver), key=version_sort_key)

    envs = run("pyenv", "virtualenvs", "--bare", "--skip-aliases").split("\n")
    venv_name_regex = re.compile(r".*/envs/(.*)")
    # Sort environments by environment name, e.g. "3.6.13/envs/gpt" -> "gpt"
    envs = sorted(
        (env for env in envs if "/envs/" in env),
        key=lambda v: venv_name_regex.search(v).groups(1),
    )

    virtualenvs = []
    for env in envs:
        print(f"Reading from {env}")
        env_prefix = run("pyenv", "prefix", env)

        output = run(f"{env_prefix}/bin/python", "-m", "pip", "list", "--format=freeze")
        contents = [line for line in output.split("\n") if line and not line.startswith("[notice]")]

        virtualenvs.append(
            {
                "fullname": env,
                "name": env.split("/", maxsplit=2)[2],
                "version": env.split("/", maxsplit=1)[0],
                "contents": contents,
            }
        )

    data = {"global_version": global_version, "versions": versions, "virtualenvs": virtualenvs}

    with open(args.output_file, "w", encoding="utf-8") as file:
        json.dump(data, file, ensure_ascii=False, indent=2)
        file.write("\n")


if __name__ == "__main__":
    main()
