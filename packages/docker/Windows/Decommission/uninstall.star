# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Windows/Decommission/uninstall.star — Uninstall phase
#
# TRIBAL KNOWLEDGE:
# Docker Desktop for Windows can be uninstalled via:
# - The installer with --uninstall flag
# - Control Panel > Programs > Uninstall
# Reference: https://docs.docker.com/desktop/uninstall/

def uninstall(system, package, plan):
    """Remove Docker Desktop from Windows."""

    # Use the uninstaller if it exists
    plan.run(
        "\"%ProgramFiles%\\Docker\\Docker\\Docker Desktop Installer.exe\" uninstall --quiet 2>nul || echo Using fallback"
    )

    # Fallback: remove program directory
    plan.remove_dir("%ProgramFiles%\\Docker")
