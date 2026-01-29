# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Linux.Fedora/Deploy/provision.star — Provision phase
#
# TRIBAL KNOWLEDGE:
# Same as Debian - add user to docker group, enable service.
# Reference: https://docs.docker.com/engine/install/linux-postinstall/

def provision(package, system, plan):
    """Configure Docker for use on Fedora/RHEL.

    Args:
        package: Package metadata and features (read-only, immediate)
        system: Query target environment (read-only, immediate)
        plan: Build execution graph (write, deferred execution)
    """

    # TODO: plan.user.add_to_group() not yet implemented
    # Add current user to docker group
    # user = system.env("USER")
    # if user and user != "root":
    #     plan.user.add_to_group(user, "docker")

    # Enable and start Docker service
    plan.service(name="docker", action="enable")
    plan.service(name="docker", action="start")

    # Rootless mode setup
    if package.has_feature("rootless"):
        plan.shell("dockerd-rootless-setuptool.sh install")

    # Configure daemon settings if custom values provided
    storage_driver = package.setting("storage-driver")
    log_driver = package.setting("log-driver")

    if storage_driver or log_driver:
        # TODO: plan.file.write() not yet implemented
        # daemon_config = '{\n'
        # if storage_driver:
        #     daemon_config += '  "storage-driver": "%s",\n' % storage_driver
        # if log_driver:
        #     daemon_config += '  "log-driver": "%s"\n' % log_driver
        # daemon_config += '}\n'
        # plan.file.write(
        #     path="/etc/docker/daemon.json",
        #     content=daemon_config,
        # )
        pass
