# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Linux.Debian/Upgrade/install.star — Install phase for upgrade

def install(system, package, plan):
    """Upgrade Docker CE packages to latest version.

    Args:
        system: Query target environment (read-only, immediate)
        package: Package metadata and features (read-only, immediate)
        plan: Build execution graph (write, deferred execution)
    """

    # Upgrade all Docker packages
    # The package manager handles version resolution
    plan.upgrade("docker-ce")
    plan.upgrade("docker-ce-cli")
    plan.upgrade("containerd.io")
    plan.upgrade("docker-buildx-plugin")
    plan.upgrade("docker-compose-plugin")

    # Upgrade rootless packages if feature enabled
    if package.feature("rootless"):
        plan.upgrade("uidmap")
        plan.upgrade("dbus-user-session")
