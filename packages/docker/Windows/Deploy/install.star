# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Windows/Deploy/install.star — Install phase
#
# TRIBAL KNOWLEDGE:
# Docker Desktop installer supports silent installation with:
#   install --quiet --accept-license
# The installer handles all component setup including CLI tools.
# Reference: https://docs.docker.com/desktop/install/windows-install/

def install(package, system, plan):
    """Install Docker Desktop on Windows.

    Args:
        package: Package metadata and features (read-only, immediate)
        system: Query target environment (read-only, immediate)
        plan: Build execution graph (write, deferred execution)
    """

    # TODO: plan.download() not yet implemented
    # plan.download(
    #     url="https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe",
    #     dest="%TEMP%\\DockerDesktopInstaller.exe",
    # )

    plan.shell(
        "%TEMP%\\DockerDesktopInstaller.exe install --quiet --accept-license"
    )

    # TODO: plan.file.remove() not yet implemented
    # plan.file.remove("%TEMP%\\DockerDesktopInstaller.exe")
