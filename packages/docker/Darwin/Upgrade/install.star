# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Darwin/Upgrade/install.star — Install phase for upgrade
#
# Docker Desktop upgrade is the same as fresh install - download new DMG
# and run the installer. It overwrites the existing installation.

def install(system, package, plan):
    """Upgrade Docker Desktop on macOS."""

    arch = system.arch()
    if arch == "arm64":
        dmg_url = "https://desktop.docker.com/mac/main/arm64/Docker.dmg"
    else:
        dmg_url = "https://desktop.docker.com/mac/main/amd64/Docker.dmg"

    plan.download(
        url=dmg_url,
        dest="/tmp/Docker.dmg",
    )

    plan.run("hdiutil attach /tmp/Docker.dmg -nobrowse -quiet")

    user = system.env("USER")
    plan.run(
        "/Volumes/Docker/Docker.app/Contents/MacOS/install --accept-license --user=%s" % user
    )

    plan.run("hdiutil detach /Volumes/Docker -quiet")
    plan.remove_file("/tmp/Docker.dmg")
