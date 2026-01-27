# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Darwin/Deploy/install.star — Install phase
#
# TRIBAL KNOWLEDGE:
# Docker Desktop for Mac is distributed as a DMG containing Docker.app.
# Installation is: mount DMG, run installer CLI, detach DMG.
# Different DMGs for Apple Silicon (arm64) vs Intel (amd64).
# Reference: https://docs.docker.com/desktop/setup/install/mac-install/

def install(system, package, plan):
    """Install Docker Desktop on macOS.

    Args:
        system: Query target environment (read-only, immediate)
        package: Package metadata and features (read-only, immediate)
        plan: Build execution graph (write, deferred execution)
    """

    # Select correct DMG for architecture
    arch = system.arch()
    if arch == "arm64":
        dmg_url = "https://desktop.docker.com/mac/main/arm64/Docker.dmg"
    else:
        dmg_url = "https://desktop.docker.com/mac/main/amd64/Docker.dmg"

    # Download Docker Desktop DMG
    dmg_path = plan.download(
        url=dmg_url,
        dest="/tmp/Docker.dmg",
    )

    # Mount the DMG
    plan.run("hdiutil attach /tmp/Docker.dmg -nobrowse -quiet")

    # Run the installer with license acceptance
    # --user flag performs privileged setup during install
    user = system.env("USER")
    plan.run(
        "/Volumes/Docker/Docker.app/Contents/MacOS/install --accept-license --user=%s" % user
    )

    # Detach the DMG
    plan.run("hdiutil detach /Volumes/Docker -quiet")

    # Clean up downloaded DMG
    plan.remove_file("/tmp/Docker.dmg")
