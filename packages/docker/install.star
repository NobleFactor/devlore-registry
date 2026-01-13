# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.

# install.star - Install phase for docker deploy pipeline
#
# This phase:
# 1. Installs docker packages via apt
#
# Logging API:
#   note(msg)    - informational, continues
#   warn(msg)    - warning, continues
#   error(msg)   - fails phase, triggers rollback
#   success(msg) - exits phase successfully

def main(lifecycle, state, features, settings):
    """Install docker packages."""

    # Get packages for apt
    packages = lifecycle.get("packages", {}).get("apt", [])

    if len(packages) == 0:
        error("No apt packages defined in lifecycle.yaml")

    # Install all packages in one transaction
    note("Installing docker packages: " + ", ".join(packages))

    result = package.install(packages)
    if not result.ok:
        error("Failed to install packages: " + result.stderr)

    # Record what was installed
    installed = []
    for name in packages:
        if package.installed(name):
            installed.append(name)
            note("  Installed: " + name)

    return {
        "packages_installed": installed,
        "install_method": "apt",
    }
