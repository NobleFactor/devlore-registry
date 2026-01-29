# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Linux.Fedora/Decommission/uninstall.star — Uninstall phase

def uninstall(package, system, plan):
    """Remove Docker CE packages on Fedora/RHEL.

    Args:
        package: Package metadata and features (read-only, immediate)
        system: Query target environment (read-only, immediate)
        plan: Build execution graph (write, deferred execution)
    """

    plan.package.remove(
        "docker-ce",
        "docker-ce-cli",
        "containerd.io",
        "docker-buildx-plugin",
        "docker-compose-plugin",
    )

    if package.has_feature("rootless"):
        plan.package.remove("fuse-overlayfs", "slirp4netns")

    # TODO: plan.package.autoremove() not yet implemented
    # plan.package.autoremove()
