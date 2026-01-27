# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Linux.Fedora/Upgrade/verify.star — Verify phase for upgrade

def verify(system, package, plan):
    """Verify Docker upgrade on Fedora/RHEL."""

    plan.restart_service("docker")
    plan.verify("docker-daemon", check="docker info")
    plan.verify("docker-version", check="docker --version")
    plan.verify("hello-world", check="docker run --rm hello-world")
