# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Linux.Fedora/Decommission/unprovision.star — Unprovision phase

def unprovision(package, system, plan):
    """Remove Docker provisioning on Fedora/RHEL.

    Args:
        package: Package metadata and features (read-only, immediate)
        system: Query target environment (read-only, immediate)
        plan: Build execution graph (write, deferred execution)
    """

    plan.shell("docker stop $(docker ps -q) 2>/dev/null || true")

    plan.service(name="docker", action="stop")
    plan.service(name="docker", action="disable")
    plan.service(name="containerd", action="stop")
    plan.service(name="containerd", action="disable")

    # TODO: plan.user.remove_from_group() not yet implemented
    # user = system.env("USER")
    # if user and user != "root":
    #     plan.user.remove_from_group(user, "docker")
