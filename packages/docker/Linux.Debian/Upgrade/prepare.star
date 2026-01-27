# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Linux.Debian/Upgrade/prepare.star — Prepare phase for upgrade

def prepare(system, package, plan):
    """Prepare for Docker CE upgrade.

    Args:
        system: Query target environment (read-only, immediate)
        package: Package metadata and features (read-only, immediate)
        plan: Build execution graph (write, deferred execution)
    """

    # Verify Docker is currently installed
    if not system.installed("docker-ce"):
        plan.fail("Docker CE is not installed - use 'lore deploy docker' instead")

    # Update package lists to get latest versions
    plan.update_package_lists()
