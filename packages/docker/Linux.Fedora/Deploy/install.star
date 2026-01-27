# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Linux.Fedora/Deploy/install.star — Install phase
#
# TRIBAL KNOWLEDGE:
# The packages are identical to Debian - only the package manager differs.
# The engine maps plan.install() to dnf on Fedora/RHEL.
# Reference: https://docs.docker.com/engine/install/rhel/

def install(system, package, plan):
    """Install Docker CE packages on Fedora/RHEL.

    Args:
        system: Query target environment (read-only, immediate)
        package: Package metadata and features (read-only, immediate)
        plan: Build execution graph (write, deferred execution)
    """

    # Core Docker packages (same as Debian)
    plan.install("docker-ce")
    plan.install("docker-ce-cli")
    plan.install("containerd.io")
    plan.install("docker-buildx-plugin")
    plan.install("docker-compose-plugin")

    # Rootless mode requires additional packages
    if package.feature("rootless"):
        plan.install("fuse-overlayfs")
        plan.install("slirp4netns")
