# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Windows/Deploy/prepare.star — Prepare phase
#
# TRIBAL KNOWLEDGE:
# Docker Desktop for Windows requires:
# - Windows 10 version 1903+ (Build 18362+) or Windows 11
# - WSL 2 backend (recommended) or Hyper-V
# - Hardware virtualization enabled in BIOS
# Reference: https://docs.docker.com/desktop/install/windows-install/

def prepare(system, package, plan):
    """Prepare Windows for Docker Desktop installation."""

    # Enable WSL feature if not already enabled
    plan.run(
        "dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart"
    )

    # Enable Virtual Machine Platform feature
    plan.run(
        "dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart"
    )

    # Set WSL 2 as default
    plan.run("wsl --set-default-version 2")

    # Install WSL 2 kernel update if needed
    plan.run("wsl --update")
