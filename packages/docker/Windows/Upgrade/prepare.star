# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Windows/Upgrade/prepare.star — Prepare phase for upgrade

def prepare(package, system, plan):
    """Prepare for Docker Desktop upgrade on Windows.

    Args:
        package: Package metadata and features (read-only, immediate)
        system: Query target environment (read-only, immediate)
        plan: Build execution graph (write, deferred execution)
    """

    # Stop all running containers before upgrade
    plan.shell("docker stop $(docker ps -q) 2>nul || echo No containers running")

    # Quit Docker Desktop
    plan.shell("taskkill /IM \"Docker Desktop.exe\" /F 2>nul || echo Docker Desktop not running")

    # Wait for processes to stop
    plan.shell("powershell -Command \"while (Get-Process 'Docker Desktop' -ErrorAction SilentlyContinue) { Start-Sleep -Seconds 1 }\"")
