# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Linux.Fedora/Decommission/cleanup.star — Cleanup phase

def cleanup(package, system, plan):
    """Clean up Docker configuration on Fedora/RHEL.

    Args:
        package: Package metadata and features (read-only, immediate)
        system: Query target environment (read-only, immediate)
        plan: Build execution graph (write, deferred execution)
    """

    # TODO: plan.file.remove() not yet implemented
    # Remove dnf repository
    # plan.file.remove("/etc/yum.repos.d/docker-ce.repo")

    # Remove Docker daemon configuration
    # plan.file.remove("/etc/docker/daemon.json")
    # plan.file.rmdir("/etc/docker")

    # Optionally purge all Docker data
    if package.has_feature("purge-data"):
        # TODO: plan.file.rmdir() not yet implemented
        # plan.file.rmdir("/var/lib/docker")
        # plan.file.rmdir("/var/lib/containerd")
        pass
