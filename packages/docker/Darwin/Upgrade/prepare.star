# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Darwin/Upgrade/prepare.star — Prepare phase for upgrade

def prepare(system, package, plan):
    """Prepare for Docker Desktop upgrade on macOS."""

    if not system.path_exists("/Applications/Docker.app"):
        plan.fail("Docker Desktop is not installed - use 'lore deploy docker' instead")

    # Quit Docker Desktop before upgrade
    plan.run("osascript -e 'quit app \"Docker\"' 2>/dev/null || true")

    # Wait for Docker to fully stop
    plan.run("while pgrep -x Docker >/dev/null; do sleep 1; done")
