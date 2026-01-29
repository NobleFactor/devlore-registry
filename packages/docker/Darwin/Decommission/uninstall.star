# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Darwin/Decommission/uninstall.star — Uninstall phase
#
# TRIBAL KNOWLEDGE:
# Docker Desktop for Mac installs to /Applications/Docker.app.
# CLI symlinks are placed in /usr/local/bin.
# Reference: https://docs.docker.com/desktop/uninstall/

def uninstall(package, system, plan):
    """Remove Docker Desktop from macOS.

    Args:
        package: Package metadata and features (read-only, immediate)
        system: Query target environment (read-only, immediate)
        plan: Build execution graph (write, deferred execution)
    """

    # TODO: plan.file.rmdir() and plan.file.remove() not yet implemented
    # Remove the application
    # plan.file.rmdir("/Applications/Docker.app")

    # Remove CLI symlinks
    # plan.file.remove("/usr/local/bin/docker")
    # plan.file.remove("/usr/local/bin/docker-compose")
    # plan.file.remove("/usr/local/bin/docker-credential-desktop")
    # plan.file.remove("/usr/local/bin/docker-credential-ecr-login")
    # plan.file.remove("/usr/local/bin/docker-credential-osxkeychain")
    # plan.file.remove("/usr/local/bin/kubectl.docker")
    # plan.file.remove("/usr/local/bin/hub-tool")
    pass
