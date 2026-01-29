# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Darwin/Upgrade/install.star — Install phase for upgrade
#
# Docker Desktop upgrade is the same as fresh install - download new DMG
# and run the installer. It overwrites the existing installation.

def install(package, system, plan):
    """Upgrade Docker Desktop on macOS.

    Args:
        package: Package metadata and features (read-only, immediate)
        system: Query target environment (read-only, immediate)
        plan: Build execution graph (write, deferred execution)
    """

    # TODO: system.arch() needs implementation
    # arch = system.arch()
    # if arch == "arm64":
    #     dmg_url = "https://desktop.docker.com/mac/main/arm64/Docker.dmg"
    # else:
    #     dmg_url = "https://desktop.docker.com/mac/main/amd64/Docker.dmg"

    # TODO: plan.download() not yet implemented
    # plan.download(
    #     url=dmg_url,
    #     dest="/tmp/Docker.dmg",
    # )

    plan.shell("hdiutil attach /tmp/Docker.dmg -nobrowse -quiet")

    # TODO: system.env() needs implementation
    # user = system.env("USER")
    # plan.shell(
    #     "/Volumes/Docker/Docker.app/Contents/MacOS/install --accept-license --user=%s" % user
    # )

    plan.shell("hdiutil detach /Volumes/Docker -quiet")

    # TODO: plan.file.remove() not yet implemented
    # plan.file.remove("/tmp/Docker.dmg")
