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

def install(system, package, plan):
    """Install Docker Desktop on Windows."""

    plan.download(
        url="https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe",
        dest="%TEMP%\\DockerDesktopInstaller.exe",
    )

    plan.run(
        "%TEMP%\\DockerDesktopInstaller.exe install --quiet --accept-license"
    )

    plan.remove_file("%TEMP%\\DockerDesktopInstaller.exe")
