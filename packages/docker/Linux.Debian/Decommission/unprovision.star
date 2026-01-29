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

def unprovision(package, system, plan):
    """Remove Docker provisioning before uninstall.

    Args:
        package: Package metadata and features (read-only, immediate)
        system: Query target environment (read-only, immediate)
        plan: Build execution graph (write, deferred execution)
    """

    # Stop all running containers
    plan.shell("docker stop $(docker ps -q) 2>/dev/null || true")

    # Stop and disable Docker service
    plan.service(name="docker", action="stop")
    plan.service(name="docker", action="disable")

    # Stop and disable containerd
    plan.service(name="containerd", action="stop")
    plan.service(name="containerd", action="disable")

    # TODO: plan.user.remove_from_group() not yet implemented
    # Remove current user from docker group
    # user = system.env("USER")
    # if user and user != "root":
    #     plan.user.remove_from_group(user, "docker")
