# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Linux.Fedora/Decommission/uninstall.star — Uninstall phase

def uninstall(system, package, plan):
    """Remove Docker CE packages on Fedora/RHEL."""

    plan.remove("docker-ce")
    plan.remove("docker-ce-cli")
    plan.remove("containerd.io")
    plan.remove("docker-buildx-plugin")
    plan.remove("docker-compose-plugin")

    if package.feature("rootless"):
        plan.remove("fuse-overlayfs")
        plan.remove("slirp4netns")

    plan.autoremove()
