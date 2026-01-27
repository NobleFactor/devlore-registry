# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Linux.Fedora/Decommission/unprovision.star — Unprovision phase

def unprovision(system, package, plan):
    """Remove Docker provisioning on Fedora/RHEL."""

    plan.run("docker stop $(docker ps -q) 2>/dev/null || true")

    plan.stop_service("docker")
    plan.disable_service("docker")
    plan.stop_service("containerd")
    plan.disable_service("containerd")

    user = system.env("USER")
    if user and user != "root":
        plan.remove_user_from_group(user, "docker")
