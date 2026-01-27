# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Windows/Upgrade/install.star — Install phase for upgrade
#
# Docker Desktop upgrade is the same as fresh install - download new
# installer and run it. It overwrites the existing installation.

def install(system, package, plan):
    """Upgrade Docker Desktop on Windows."""

    plan.download(
        url="https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe",
        dest="%TEMP%\\DockerDesktopInstaller.exe",
    )

    plan.run(
        "%TEMP%\\DockerDesktopInstaller.exe install --quiet --accept-license"
    )

    plan.remove_file("%TEMP%\\DockerDesktopInstaller.exe")
