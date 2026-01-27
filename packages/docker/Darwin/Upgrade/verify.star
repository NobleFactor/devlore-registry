# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Darwin/Upgrade/verify.star — Verify phase for upgrade

def verify(system, package, plan):
    """Verify Docker Desktop upgrade on macOS."""

    # Start Docker Desktop
    plan.run("open -a Docker")

    # Wait for daemon to be ready
    plan.run("while ! docker info >/dev/null 2>&1; do sleep 1; done")

    plan.verify("docker-daemon", check="docker info")
    plan.verify("docker-version", check="docker --version")
    plan.verify("hello-world", check="docker run --rm hello-world")
