# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Linux.Fedora/Deploy/install.star — Install phase
#
# TRIBAL KNOWLEDGE:
# The packages are identical to Debian - only the package manager differs.
# The engine maps plan.package.install() to dnf on Fedora/RHEL.
# Reference: https://docs.docker.com/engine/install/rhel/

def install(package, system, plan):
    """Install Docker CE packages on Fedora/RHEL.

    Args:
        package: Package metadata and features (read-only, immediate)
        system: Query target environment (read-only, immediate)
        plan: Build execution graph (write, deferred execution)
    """

    # Core Docker packages (same as Debian)
    plan.package.install(
        "docker-ce",
        "docker-ce-cli",
        "containerd.io",
        "docker-buildx-plugin",
        "docker-compose-plugin",
    )

    # Rootless mode requires additional packages
    if package.has_feature("rootless"):
        plan.package.install("fuse-overlayfs", "slirp4netns")
