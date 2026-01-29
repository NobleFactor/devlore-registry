# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Linux.Debian/Upgrade/verify.star — Verify phase for upgrade

def verify(package, system, plan):
    """Verify Docker upgrade completed successfully.

    Args:
        package: Package metadata and features (read-only, immediate)
        system: Query target environment (read-only, immediate)
        plan: Build execution graph (write, deferred execution)
    """

    # Restart Docker to pick up any changes
    plan.service(name="docker", action="restart")

    # Verify docker daemon is running
    plan.verify("docker-daemon", check="docker info")

    # Verify version updated
    plan.verify("docker-version", check="docker --version")

    # Run hello-world smoke test
    plan.verify("hello-world", check="docker run --rm hello-world")
