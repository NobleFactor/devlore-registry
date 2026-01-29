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

def provision(package, system, plan):
    """Configure Docker Desktop after installation.

    Args:
        package: Package metadata and features (read-only, immediate)
        system: Query target environment (read-only, immediate)
        plan: Build execution graph (write, deferred execution)
    """

    # TODO: system.env() needs implementation
    # Add current user to docker-users group for non-admin access
    # user = system.env("USERNAME")
    # plan.shell(
    #     "net localgroup docker-users %s /add 2>nul || echo Already a member" % user
    # )

    # Start Docker Desktop
    plan.shell(
        "start \"\" \"%ProgramFiles%\\Docker\\Docker\\Docker Desktop.exe\""
    )
