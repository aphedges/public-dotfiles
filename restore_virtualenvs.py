"""Script to restore pyenv versions and pyenv-virtualenv environments from a JSON format."""

import argparse
import json
import os
from pathlib import Path
import platform
import re
import shutil
import subprocess
import tempfile
from typing import Mapping, Optional, Sequence


def run(*args: str, env: Optional[Mapping[str, str]] = None) -> None:
    """Runs an external command to obtain its output.

    Args:
        *args: Components of the command to run.
        env: Optional environment variables to use.
    """
    subprocess.run(args, check=True, encoding="utf-8", env=env)


def run_with_output(*args: str) -> str:
    """Runs an external command to obtain its output.

    Args:
        *args: Components of the command to run.

    Returns:
        Command output.
    """
    return subprocess.check_output(args, encoding="utf-8", stderr=subprocess.DEVNULL).strip()


def get_installed_versions() -> Sequence[str]:
    """Retrieves all versions and virtualenvs installed with pyenv.

    Returns:
        Installed versions.
    """
    return run_with_output("pyenv", "versions", "--bare").split()


def install_requirements(
    pip_exec: str, requirements: Sequence[str], use_system_version_compat: bool = True
) -> None:
    """Installs requirements in an environment.

    Args:
        pip_exec: Path to pip executable.
        requirements: List of requirements to install.
        use_system_version_compat: Install requirement as if on macOS 10.16.
    """
    requirements = "\n".join(requirements) + "\n"
    env = {**os.environ, "SYSTEM_VERSION_COMPAT": "1"} if use_system_version_compat else None
    with tempfile.NamedTemporaryFile("w", encoding="utf-8") as file:
        file.write(requirements)
        file.flush()  # Needed to prevent an empty file
        run(pip_exec, "install", "-r", file.name, env=env)


def main() -> None:
    """Restores contents of pyenv."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--input-file",
        default=Path("virtualenvs.json"),
        type=Path,
        help="File to load pyenv contents from.",
    )
    args = parser.parse_args()

    if not args.input_file.is_file():
        raise OSError(f"Input file '{args.input_file}' does not exist.")

    with open(args.input_file, encoding="utf-8") as file:
        data = json.load(file)

    installed_versions = get_installed_versions()
    for version in data["versions"]:
        if version in installed_versions:
            print(f"Python {version} is already installed. Skipping installation.")
            continue

        # Older versions of Python cannot compile on macOS 11 or later
        if (
            platform.system() == "Darwin"
            and int(platform.release().split(".", maxsplit=1)[0]) >= 20
        ):
            match = re.fullmatch(r"(\d+).(\d+).(\d+)", version)
            if match:
                version_tuple = tuple(int(i) for i in match.groups())
                if (
                    version_tuple < (2, 7, 18)
                    or (3,) <= version_tuple < (3, 6)
                    or (3, 6) <= version_tuple < (3, 6, 15)
                    or (3, 7) <= version_tuple < (3, 7, 8)
                    or (3, 8) <= version_tuple < (3, 8, 4)
                ):
                    print(
                        f"Cannot install Python {version} on macOS 11 or later. Skipping version."
                    )
                    continue

        print(f"Installing version {version}")
        run("pyenv", "install", version)

    installed_versions = get_installed_versions()
    for virtualenv in data["virtualenvs"]:
        if virtualenv["version"] not in installed_versions:
            print(
                f"virtualenv {virtualenv['name']} depends on a Python version "
                "that is not installed. Skipping creation."
            )
            continue

        if virtualenv["version"].startswith(("anaconda", "miniconda")):
            print(
                f"virtualenv {virtualenv['name']} is actually a conda environment, "
                "which this script cannot handle. Skipping creation."
            )
            continue

        if virtualenv["name"] in installed_versions:
            print(f"virtualenv {virtualenv['name']} already exists. Skipping creation.")
        else:
            print(f"Creating virtualenv {virtualenv['fullname']} with {virtualenv['version']}")
            run("pyenv", "virtualenv", virtualenv["version"], virtualenv["name"])

        print(f"Installing packages in virtualenv {virtualenv['name']}")
        env_dir = run_with_output("pyenv", "prefix", virtualenv["name"])
        pip_exec = f"{env_dir}/bin/pip"
        setup_requirements = [
            p for p in virtualenv["contents"] if p.split("==")[0] in {"pip", "setuptools", "wheel"}
        ]
        install_requirements(pip_exec, setup_requirements)
        # Uninstall `setuptools` if not in original requirements
        # `setuptools` is automatically installed in environments for Python 3.11 and older
        if not any(req.startswith("setuptools==") for req in setup_requirements):
            run(pip_exec, "uninstall", "--yes", "setuptools")
        match = re.fullmatch(
            r"pip (\d+).(\d+)(?:.(\d+))? .*", run_with_output(pip_exec, "--version")
        )
        if match is None:
            print(f"Could not determine pip version in virtualenv {virtualenv['name']}")
            use_system_version_compat = False
        else:
            pip_version = tuple(int(i) for i in match.groups() if i is not None)
            use_system_version_compat = pip_version < (20, 3) and platform.system() == "Darwin"
        install_requirements(pip_exec, virtualenv["contents"], use_system_version_compat)

    print(f"Setting global version to {data['global_version']}")
    run("pyenv", "global", data["global_version"])

    if data.get("pipx_spec_metadata"):
        pipx_path = shutil.which("pipx")
        if pipx_path:
            print("Installing packages in pipx")
            pipx_spec_metadata = data["pipx_spec_metadata"]
            with tempfile.NamedTemporaryFile("w", encoding="utf-8") as file:
                file.write(json.dumps(pipx_spec_metadata))
                file.flush()  # Needed to prevent an empty file
                run(pipx_path, "install-all", file.name)
        else:
            print("`pipx` is not in `PATH`. Skipping `pipx` state restoration.")


if __name__ == "__main__":
    main()
