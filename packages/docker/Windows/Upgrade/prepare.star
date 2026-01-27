# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Windows/Upgrade/prepare.star — Prepare phase for upgrade

def prepare(system, package, plan):
    """Prepare for Docker Desktop upgrade on Windows."""

    # Stop all running containers before upgrade
    plan.run("docker stop $(docker ps -q) 2>nul || echo No containers running")

    # Quit Docker Desktop
    plan.run("taskkill /IM \"Docker Desktop.exe\" /F 2>nul || echo Docker Desktop not running")

    # Wait for processes to stop
    plan.run("powershell -Command \"while (Get-Process 'Docker Desktop' -ErrorAction SilentlyContinue) { Start-Sleep -Seconds 1 }\"")
