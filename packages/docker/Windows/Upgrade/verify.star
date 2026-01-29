# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Windows/Upgrade/verify.star — Verify phase for upgrade

def verify(package, system, plan):
    """Verify Docker Desktop upgrade on Windows.

    Args:
        package: Package metadata and features (read-only, immediate)
        system: Query target environment (read-only, immediate)
        plan: Build execution graph (write, deferred execution)
    """

    # Start Docker Desktop
    plan.shell(
        "start \"\" \"%ProgramFiles%\\Docker\\Docker\\Docker Desktop.exe\""
    )

    # Wait for daemon to be ready
    plan.shell("powershell -Command \"while (-not (docker info 2>$null)) { Start-Sleep -Seconds 1 }\"")

    plan.verify("docker-daemon", check="docker info")
    plan.verify("docker-version", check="docker --version")
    plan.verify("hello-world", check="docker run --rm hello-world")
