# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Windows/Upgrade/verify.star — Verify phase for upgrade

def verify(system, package, plan):
    """Verify Docker Desktop upgrade on Windows."""

    # Start Docker Desktop
    plan.run(
        "start \"\" \"%ProgramFiles%\\Docker\\Docker\\Docker Desktop.exe\""
    )

    # Wait for daemon to be ready
    plan.run("powershell -Command \"while (-not (docker info 2>$null)) { Start-Sleep -Seconds 1 }\"")

    plan.verify("docker-daemon", check="docker info")
    plan.verify("docker-version", check="docker --version")
    plan.verify("hello-world", check="docker run --rm hello-world")
