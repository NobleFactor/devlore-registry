# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Linux.Debian/Decommission/uninstall.star — Uninstall phase

def uninstall(package, system, plan):
    """Remove Docker CE packages.

    Args:
        package: Package metadata and features (read-only, immediate)
        system: Query target environment (read-only, immediate)
        plan: Build execution graph (write, deferred execution)
    """

    # Remove all Docker packages
    plan.package.remove(
        "docker-ce",
        "docker-ce-cli",
        "containerd.io",
        "docker-buildx-plugin",
        "docker-compose-plugin",
    )

    # Remove rootless packages if they were installed
    if package.has_feature("rootless"):
        plan.package.remove("uidmap", "dbus-user-session")

    # TODO: plan.package.autoremove() not yet implemented
    # Clean up orphaned dependencies
    # plan.package.autoremove()
