# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Linux.Fedora/Deploy/provision.star — Provision phase
#
# TRIBAL KNOWLEDGE:
# Same as Debian - add user to docker group, enable service.
# Reference: https://docs.docker.com/engine/install/linux-postinstall/

def provision(system, package, plan):
    """Configure Docker for use on Fedora/RHEL.

    Args:
        system: Query target environment (read-only, immediate)
        package: Package metadata and features (read-only, immediate)
        plan: Build execution graph (write, deferred execution)
    """

    # Add current user to docker group
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
