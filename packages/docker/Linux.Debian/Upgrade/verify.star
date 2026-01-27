# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Linux.Debian/Upgrade/verify.star — Verify phase for upgrade

def verify(system, package, plan):
    """Verify Docker upgrade completed successfully.

    Args:
        system: Query target environment (read-only, immediate)
        package: Package metadata and features (read-only, immediate)
        plan: Build execution graph (write, deferred execution)
    """

    # Restart Docker to pick up any changes
    plan.restart_service("docker")

    # Verify docker daemon is running
    plan.verify("docker-daemon", check="docker info")

    # Verify version updated
    plan.verify("docker-version", check="docker --version")

    # Run hello-world smoke test
    plan.verify("hello-world", check="docker run --rm hello-world")
