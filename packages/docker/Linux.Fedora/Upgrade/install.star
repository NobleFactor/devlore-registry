# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Linux.Fedora/Upgrade/install.star — Install phase for upgrade

def install(system, package, plan):
    """Upgrade Docker CE packages on Fedora/RHEL."""

    plan.upgrade("docker-ce")
    plan.upgrade("docker-ce-cli")
    plan.upgrade("containerd.io")
    plan.upgrade("docker-buildx-plugin")
    plan.upgrade("docker-compose-plugin")

    if package.feature("rootless"):
        plan.upgrade("fuse-overlayfs")
        plan.upgrade("slirp4netns")
