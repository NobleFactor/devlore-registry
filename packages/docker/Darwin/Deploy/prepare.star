# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Darwin/Deploy/prepare.star — Prepare phase
#
# TRIBAL KNOWLEDGE:
# Docker Desktop for Mac is a proprietary application, not Docker CE.
# Licensing: Free for small businesses (<250 employees, <$10M revenue),
# personal use, education, non-commercial OSS. Requires paid subscription
# for larger enterprises.
#
# Apple Silicon Macs benefit from Rosetta 2 for some CLI tools.
# Reference: https://docs.docker.com/desktop/setup/install/mac-install/

def prepare(system, package, plan):
    """Prepare for Docker Desktop installation on macOS.

    Args:
        system: Query target environment (read-only, immediate)
        package: Package metadata and features (read-only, immediate)
        plan: Build execution graph (write, deferred execution)
    """

    # Check macOS version (Docker Desktop requires current or 2 previous major versions)
    # This is informational - the installer will fail if unsupported
    plan.verify(
        "macos-version",
        check="sw_vers -productVersion",
        optional=True,
    )

    # Install Rosetta 2 on Apple Silicon (recommended but not required)
    arch = system.arch()
    if arch == "arm64":
        if not system.path_exists("/Library/Apple/usr/share/rosetta"):
            plan.run("softwareupdate --install-rosetta --agree-to-license")

    # Quit applications that might interfere with Docker installation
    # (VS Code, terminals with Docker plugins, etc.)
    plan.notify(
        "Please quit applications that may use Docker (VS Code, terminals) before proceeding."
    )
