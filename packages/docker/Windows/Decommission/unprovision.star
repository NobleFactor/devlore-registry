# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Windows/Decommission/unprovision.star — Unprovision phase

def unprovision(system, package, plan):
    """Stop Docker Desktop before removal."""

    # Stop all running containers
    plan.run("docker stop $(docker ps -q) 2>nul || echo No containers running")

    # Quit Docker Desktop
    plan.run("taskkill /IM \"Docker Desktop.exe\" /F 2>nul || echo Docker Desktop not running")
    plan.run("taskkill /IM \"com.docker.backend.exe\" /F 2>nul || echo Backend not running")

    # Wait for processes to stop
    plan.run("powershell -Command \"while (Get-Process 'Docker Desktop' -ErrorAction SilentlyContinue) { Start-Sleep -Seconds 1 }\"")
