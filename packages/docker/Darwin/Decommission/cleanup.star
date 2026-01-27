# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Darwin/Decommission/cleanup.star — Cleanup phase
#
# TRIBAL KNOWLEDGE:
# Docker Desktop stores data in several locations:
# - ~/Library/Group Containers/group.com.docker/
# - ~/Library/Containers/com.docker.docker/
# - ~/Library/Application Support/Docker Desktop/
# - ~/.docker/

def cleanup(system, package, plan):
    """Clean up Docker Desktop data on macOS."""

    user_home = system.env("HOME")

    # Remove Docker Desktop preferences and state
    plan.remove_dir("%s/Library/Application Support/Docker Desktop" % user_home)
    plan.remove_dir("%s/Library/Preferences/com.docker.docker.plist" % user_home)
    plan.remove_dir("%s/Library/Saved Application State/com.electron.docker-frontend.savedState" % user_home)

    # Remove Docker CLI config
    plan.remove_dir("%s/.docker" % user_home)

    # Optionally purge all Docker data (images, containers, volumes)
    if package.feature("purge-data"):
        plan.remove_dir("%s/Library/Group Containers/group.com.docker" % user_home)
        plan.remove_dir("%s/Library/Containers/com.docker.docker" % user_home)
