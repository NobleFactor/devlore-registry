# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Linux.Debian/Decommission/uninstall.star — Uninstall phase

def uninstall(system, package, plan):
    """Remove Docker CE packages.

    Args:
        system: Query target environment (read-only, immediate)
        package: Package metadata and features (read-only, immediate)
        plan: Build execution graph (write, deferred execution)
    """

    # Remove all Docker packages
    plan.remove("docker-ce")
    plan.remove("docker-ce-cli")
    plan.remove("containerd.io")
    plan.remove("docker-buildx-plugin")
    plan.remove("docker-compose-plugin")

    # Remove rootless packages if they were installed
    if package.feature("rootless"):
        plan.remove("uidmap")
        plan.remove("dbus-user-session")

    # Clean up orphaned dependencies
    plan.autoremove()
