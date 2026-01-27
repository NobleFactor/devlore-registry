# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Linux.Debian/Decommission/unprovision.star — Unprovision phase
#
# TRIBAL KNOWLEDGE:
# Before removing Docker, we should:
# 1. Stop any running containers
# 2. Stop and disable the Docker service
# 3. Optionally remove user from docker group

def unprovision(system, package, plan):
    """Remove Docker provisioning before uninstall.

    Args:
        system: Query target environment (read-only, immediate)
        package: Package metadata and features (read-only, immediate)
        plan: Build execution graph (write, deferred execution)
    """

    # Stop all running containers
    plan.run("docker stop $(docker ps -q) 2>/dev/null || true")

    # Stop and disable Docker service
    plan.stop_service("docker")
    plan.disable_service("docker")

    # Stop containerd
    plan.stop_service("containerd")
    plan.disable_service("containerd")

    # Remove current user from docker group
    user = system.env("USER")
    if user and user != "root":
        plan.remove_user_from_group(user, "docker")
