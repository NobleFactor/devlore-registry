# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# docker/Linux.Fedora/Upgrade/prepare.star — Prepare phase for upgrade

def prepare(system, package, plan):
    """Prepare for Docker CE upgrade on Fedora/RHEL."""

    if not system.installed("docker-ce"):
        plan.fail("Docker CE is not installed - use 'lore deploy docker' instead")

    plan.update_package_lists()
