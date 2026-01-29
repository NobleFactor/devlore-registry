# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Darwin/Decommission/unprovision.star — Unprovision phase

def unprovision(package, system, plan):
    """Stop Docker Desktop before removal.

    Args:
        package: Package metadata and features (read-only, immediate)
        system: Query target environment (read-only, immediate)
        plan: Build execution graph (write, deferred execution)
    """

    # Stop all running containers
    plan.shell("docker stop $(docker ps -q) 2>/dev/null || true")

    # Quit Docker Desktop
    plan.shell("osascript -e 'quit app \"Docker\"' 2>/dev/null || true")

    # Wait for Docker to fully stop
    plan.shell("while pgrep -x Docker >/dev/null; do sleep 1; done")
