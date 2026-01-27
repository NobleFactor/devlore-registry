# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Darwin/Decommission/unprovision.star — Unprovision phase

def unprovision(system, package, plan):
    """Stop Docker Desktop before removal."""

    # Stop all running containers
    plan.run("docker stop $(docker ps -q) 2>/dev/null || true")

    # Quit Docker Desktop
    plan.run("osascript -e 'quit app \"Docker\"' 2>/dev/null || true")

    # Wait for Docker to fully stop
    plan.run("while pgrep -x Docker >/dev/null; do sleep 1; done")
