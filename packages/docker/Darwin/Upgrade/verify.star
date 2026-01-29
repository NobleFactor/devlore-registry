# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Darwin/Upgrade/verify.star — Verify phase for upgrade

def verify(package, system, plan):
    """Verify Docker Desktop upgrade on macOS.

    Args:
        package: Package metadata and features (read-only, immediate)
        system: Query target environment (read-only, immediate)
        plan: Build execution graph (write, deferred execution)
    """

    # Start Docker Desktop
    plan.shell("open -a Docker")

    # Wait for daemon to be ready
    plan.shell("while ! docker info >/dev/null 2>&1; do sleep 1; done")

    plan.verify("docker-daemon", check="docker info")
    plan.verify("docker-version", check="docker --version")
    plan.verify("hello-world", check="docker run --rm hello-world")
