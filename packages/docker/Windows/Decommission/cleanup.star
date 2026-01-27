# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Windows/Decommission/cleanup.star — Cleanup phase
#
# TRIBAL KNOWLEDGE:
# Docker Desktop stores data in several locations:
# - %LOCALAPPDATA%\Docker\
# - %APPDATA%\Docker\
# - %USERPROFILE%\.docker\
# - WSL 2 distros: docker-desktop and docker-desktop-data

def cleanup(system, package, plan):
    """Clean up Docker Desktop data on Windows."""

    # Remove Docker Desktop settings and state
    plan.remove_dir("%LOCALAPPDATA%\\Docker")
    plan.remove_dir("%APPDATA%\\Docker")
    plan.remove_dir("%APPDATA%\\Docker Desktop")

    # Remove Docker CLI config
    plan.remove_dir("%USERPROFILE%\\.docker")

    # Optionally purge all Docker data (images, containers, volumes)
    if package.feature("purge-data"):
        # Remove WSL 2 Docker distros
        plan.run("wsl --unregister docker-desktop 2>nul || echo Not found")
        plan.run("wsl --unregister docker-desktop-data 2>nul || echo Not found")
