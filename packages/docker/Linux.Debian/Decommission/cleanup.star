# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Linux.Debian/Decommission/cleanup.star — Cleanup phase
#
# TRIBAL KNOWLEDGE:
# Docker leaves behind several directories that may contain user data:
# - /var/lib/docker: Images, containers, volumes
# - /var/lib/containerd: Containerd state
# - /etc/docker: Configuration (daemon.json)
# - /etc/apt/sources.list.d/docker.list: Apt repository
# - /etc/apt/keyrings/docker.asc: GPG key
#
# This phase removes configuration but preserves data by default.
# Use --with purge-data to remove everything including images/volumes.

def cleanup(system, package, plan):
    """Clean up Docker configuration and optionally data.

    Args:
        system: Query target environment (read-only, immediate)
        package: Package metadata and features (read-only, immediate)
        plan: Build execution graph (write, deferred execution)
    """

    # Remove apt repository configuration
    plan.remove_file("/etc/apt/sources.list.d/docker.list")
    plan.remove_file("/etc/apt/keyrings/docker.asc")

    # Remove Docker daemon configuration
    plan.remove_file("/etc/docker/daemon.json")
    plan.remove_dir("/etc/docker")

    # Optionally purge all Docker data (images, containers, volumes)
    # This is destructive and requires explicit opt-in
    if package.feature("purge-data"):
        plan.remove_dir("/var/lib/docker")
        plan.remove_dir("/var/lib/containerd")
