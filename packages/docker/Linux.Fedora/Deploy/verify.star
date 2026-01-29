# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Linux.Fedora/Deploy/verify.star — Verify phase
#
# Same verification as Debian.

def verify(package, system, plan):
    """Verify Docker installation on Fedora/RHEL.

    Args:
        package: Package metadata and features (read-only, immediate)
        system: Query target environment (read-only, immediate)
        plan: Build execution graph (write, deferred execution)
    """

    plan.verify("docker-command", check="which docker")
    plan.verify("docker-daemon", check="docker info")
    plan.verify("docker-compose", check="docker compose version")
    plan.verify("hello-world", check="docker run --rm hello-world")
