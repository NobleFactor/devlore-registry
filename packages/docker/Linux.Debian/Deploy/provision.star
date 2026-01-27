# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Linux.Debian/Deploy/provision.star — Provision phase
#
# TRIBAL KNOWLEDGE:
# 1. User must be added to 'docker' group to run docker without sudo.
#    A logout/login is required for group membership to take effect.
#
# 2. ODROID-C4/C5 boards require cgroup v1 compatibility mode.
#    Without this, Docker containers fail to start.
#    Fix: Add systemd.unified_cgroup_hierarchy=0 to boot.ini
#    Reference: https://sipfront.com/blog/2024/01/running-docker-on-odroid-c4/
#
# 3. Rootless mode requires running dockerd-rootless-setuptool.sh

def provision(system, package, plan):
    """Configure Docker for use on this system.

    Args:
        system: Query target environment (read-only, immediate)
        package: Package metadata and features (read-only, immediate)
        plan: Build execution graph (write, deferred execution)
    """

    # Add current user to docker group
    # This allows running docker commands without sudo
    user = system.env("USER")
    if user and user != "root":
        plan.add_user_to_group(user, "docker")

    # Enable and start Docker service
    plan.enable_service("docker")
    plan.start_service("docker")

    # Rootless mode setup
    if package.feature("rootless"):
        plan.run("dockerd-rootless-setuptool.sh install")

    # Configure daemon settings if custom values provided
    storage_driver = package.setting("storage-driver", "overlay2")
    log_driver = package.setting("log-driver", "json-file")

    if storage_driver != "overlay2" or log_driver != "json-file":
        daemon_config = '{\n'
        daemon_config += '  "storage-driver": "%s",\n' % storage_driver
        daemon_config += '  "log-driver": "%s"\n' % log_driver
        daemon_config += '}\n'

        plan.write_file(
            path="/etc/docker/daemon.json",
            content=daemon_config,
        )
