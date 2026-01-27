# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Linux.Fedora/Deploy/prepare.star — Prepare phase
#
# TRIBAL KNOWLEDGE:
# Fedora/RHEL/CentOS have different conflicting packages than Debian.
# The Docker repo file can be downloaded directly (includes GPG key reference).
# Reference: https://docs.docker.com/engine/install/rhel/

def prepare(system, package, plan):
    """Prepare the system for Docker CE installation on Fedora/RHEL.

    Args:
        system: Query target environment (read-only, immediate)
        package: Package metadata and features (read-only, immediate)
        plan: Build execution graph (write, deferred execution)
    """

    # Remove conflicting packages
    # These are the Fedora/RHEL/CentOS packages that conflict with Docker CE
    conflicts = [
        "docker",
        "docker-client",
        "docker-client-latest",
        "docker-common",
        "docker-latest",
        "docker-latest-logrotate",
        "docker-logrotate",
        "docker-engine",
        "podman",
        "runc",
    ]

    for pkg in conflicts:
        if system.installed(pkg):
            plan.remove(pkg)

    # Install dnf plugins for repo management
    plan.install("dnf-plugins-core")

    # Download Docker's official repo file
    # This includes the GPG key reference, so no separate key download needed
    plan.download(
        url="https://download.docker.com/linux/rhel/docker-ce.repo",
        dest="/etc/yum.repos.d/docker-ce.repo",
    )

    # Update package lists to pick up the new repository
    plan.update_package_lists()
