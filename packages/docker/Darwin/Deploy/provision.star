# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Darwin/Deploy/provision.star — Provision phase
#
# TRIBAL KNOWLEDGE:
# Docker Desktop manages its own daemon - no systemctl needed.
# Starting Docker.app launches the Docker daemon automatically.
# CLI tools (docker, docker-compose) are symlinked to /usr/local/bin.
# Reference: https://docs.docker.com/desktop/setup/install/mac-install/

def provision(system, package, plan):
    """Configure Docker Desktop on macOS.

    Args:
        system: Query target environment (read-only, immediate)
        package: Package metadata and features (read-only, immediate)
        plan: Build execution graph (write, deferred execution)
    """

    # Start Docker Desktop
    # The app manages the daemon lifecycle
    plan.run("open -a Docker")

    # Wait for Docker to be ready (daemon startup takes a few seconds)
    plan.run("while ! docker info >/dev/null 2>&1; do sleep 1; done")

    # Docker Desktop handles daemon.json internally via its settings UI
    # Custom storage-driver and log-driver settings would need to be
    # configured through Docker Desktop preferences, not daemon.json
    storage_driver = package.setting("storage-driver", "overlay2")
    log_driver = package.setting("log-driver", "json-file")

    if storage_driver != "overlay2" or log_driver != "json-file":
        plan.notify(
            "Custom storage-driver and log-driver settings must be configured "
            "through Docker Desktop > Settings > Docker Engine."
        )
