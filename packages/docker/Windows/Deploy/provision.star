# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Windows/Deploy/provision.star — Provision phase
#
# TRIBAL KNOWLEDGE:
# Docker Desktop on Windows:
# - Adds docker CLI to PATH automatically
# - Creates docker-users group for non-admin access
# - Starts Docker Desktop service on login

def provision(system, package, plan):
    """Configure Docker Desktop after installation."""

    # Add current user to docker-users group for non-admin access
    user = system.env("USERNAME")
    plan.run(
        "net localgroup docker-users %s /add 2>nul || echo Already a member" % user
    )

    # Start Docker Desktop
    plan.run(
        "start \"\" \"%ProgramFiles%\\Docker\\Docker\\Docker Desktop.exe\""
    )
