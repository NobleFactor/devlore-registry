# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Linux.Fedora/Upgrade/install.star — Install phase for upgrade

def install(package, system, plan):
    """Upgrade Docker CE packages on Fedora/RHEL.

    Args:
        package: Package metadata and features (read-only, immediate)
        system: Query target environment (read-only, immediate)
        plan: Build execution graph (write, deferred execution)
    """

    plan.package.upgrade(
        "docker-ce",
        "docker-ce-cli",
        "containerd.io",
        "docker-buildx-plugin",
        "docker-compose-plugin",
    )

    if package.has_feature("rootless"):
        plan.package.upgrade("fuse-overlayfs", "slirp4netns")
