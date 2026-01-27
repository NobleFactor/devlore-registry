# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Linux.Fedora/Decommission/cleanup.star — Cleanup phase

def cleanup(system, package, plan):
    """Clean up Docker configuration on Fedora/RHEL."""

    # Remove dnf repository
    plan.remove_file("/etc/yum.repos.d/docker-ce.repo")

    # Remove Docker daemon configuration
    plan.remove_file("/etc/docker/daemon.json")
    plan.remove_dir("/etc/docker")

    # Optionally purge all Docker data
    if package.feature("purge-data"):
        plan.remove_dir("/var/lib/docker")
        plan.remove_dir("/var/lib/containerd")
