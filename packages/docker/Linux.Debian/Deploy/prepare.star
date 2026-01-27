# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Linux.Debian/Deploy/prepare.star — Prepare phase
#
# TRIBAL KNOWLEDGE:
# Docker CE requires removing conflicting system packages first.
# The official Docker apt repository must be configured before install.
# Reference: https://docs.docker.com/engine/install/ubuntu/

def prepare(system, package, plan):
    """Prepare the system for Docker CE installation.

    Args:
        system: Query target environment (read-only, immediate)
        package: Package metadata and features (read-only, immediate)
        plan: Build execution graph (write, deferred execution)
    """

    # Remove conflicting packages
    # These are the Ubuntu/Debian packages that conflict with Docker CE
    conflicts = [
        "docker.io",
        "docker-doc",
        "docker-compose",
        "docker-compose-v2",
        "podman-docker",
        "containerd",
        "runc",
    ]

    for pkg in conflicts:
        if system.installed(pkg):
            plan.remove(pkg)

    # Set up Docker's official apt repository
    # 1. Install prerequisites for HTTPS apt repos
    plan.install("ca-certificates")
    plan.install("curl")

    # 2. Download and install Docker's GPG key
    gpg_key = plan.download(
        url="https://download.docker.com/linux/ubuntu/gpg",
        dest="/etc/apt/keyrings/docker.asc",
    )
    plan.chmod(gpg_key, "a+r")

    # 3. Add the Docker apt repository
    # Uses system.arch() to get the correct architecture (amd64, arm64)
    arch = system.arch()
    codename = system.codename()  # e.g., "jammy", "noble"

    repo_line = "deb [arch=%s signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu %s stable" % (arch, codename)

    plan.write_file(
        path="/etc/apt/sources.list.d/docker.list",
        content=repo_line + "\n",
    )

    # 4. Update package lists to pick up the new repository
    plan.update_package_lists()
