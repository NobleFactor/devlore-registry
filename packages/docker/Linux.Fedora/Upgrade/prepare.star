# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Linux.Fedora/Upgrade/prepare.star — Prepare phase for upgrade

def prepare(package, system, plan):
    """Prepare for Docker CE upgrade on Fedora/RHEL.

    Args:
        package: Package metadata and features (read-only, immediate)
        system: Query target environment (read-only, immediate)
        plan: Build execution graph (write, deferred execution)
    """

    if not system.package.installed("docker-ce"):
        # TODO: plan.fail() not yet implemented
        # plan.fail("Docker CE is not installed - use 'lore deploy docker' instead")
        pass

    plan.package.update()
