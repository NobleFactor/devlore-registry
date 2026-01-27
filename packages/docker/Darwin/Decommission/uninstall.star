# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Darwin/Decommission/uninstall.star — Uninstall phase
#
# TRIBAL KNOWLEDGE:
# Docker Desktop for Mac installs to /Applications/Docker.app.
# CLI symlinks are placed in /usr/local/bin.
# Reference: https://docs.docker.com/desktop/uninstall/

def uninstall(system, package, plan):
    """Remove Docker Desktop from macOS."""

    # Remove the application
    plan.remove_dir("/Applications/Docker.app")

    # Remove CLI symlinks
    plan.remove_file("/usr/local/bin/docker")
    plan.remove_file("/usr/local/bin/docker-compose")
    plan.remove_file("/usr/local/bin/docker-credential-desktop")
    plan.remove_file("/usr/local/bin/docker-credential-ecr-login")
    plan.remove_file("/usr/local/bin/docker-credential-osxkeychain")
    plan.remove_file("/usr/local/bin/kubectl.docker")
    plan.remove_file("/usr/local/bin/hub-tool")
