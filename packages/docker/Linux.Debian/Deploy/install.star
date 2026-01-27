# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Linux.Debian/Deploy/install.star — Install phase
#
# TRIBAL KNOWLEDGE:
# Docker CE on Debian/Ubuntu consists of multiple packages:
# - docker-ce: The Docker daemon
# - docker-ce-cli: The docker command-line tool
# - containerd.io: The container runtime (Docker's version, not system)
# - docker-buildx-plugin: BuildKit-based builder
# - docker-compose-plugin: Compose V2 as a Docker plugin
# - lshw: For hardware detection in verify phase (ODROID support)
#
# Reference: https://docs.docker.com/engine/install/ubuntu/

def install(system, package, plan):
    """Install Docker CE packages.

    Args:
        system: Query target environment (read-only, immediate)
        package: Package metadata and features (read-only, immediate)
        plan: Build execution graph (write, deferred execution)
    """

    # Core Docker packages
    plan.install("docker-ce")
    plan.install("docker-ce-cli")
    plan.install("containerd.io")
    plan.install("docker-buildx-plugin")
    plan.install("docker-compose-plugin")

    # Hardware detection utility (needed for ODROID verification)
    plan.install("lshw")

    # Rootless mode requires additional packages
    if package.feature("rootless"):
        plan.install("uidmap")
        plan.install("dbus-user-session")
