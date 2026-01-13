# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.

# prepare.star - Prepare phase for docker deploy pipeline
#
# This phase:
# 1. Verifies we're on a supported platform (Linux)
# 2. Removes conflicting packages
# 3. Updates package lists
#
# Logging API:
#   note(msg)    - informational, continues
#   warn(msg)    - warning, continues
#   error(msg)   - fails phase, triggers rollback
#   success(msg) - exits phase successfully

def main(lifecycle, state, features, settings):
    """Prepare the system for docker deployment."""

    note("Preparing docker deployment")
    note("Platform: os=%s, arch=%s, distro=%s" % (platform.os, platform.arch, platform.distro))

    # Check platform
    if platform.os != "linux":
        error("docker package requires Linux, got: " + platform.os)

    # Remove conflicting packages
    conflicts = lifecycle.get("conflicts", [])
    removed = []

    for name in conflicts:
        if package.installed(name):
            note("Removing conflicting package: " + name)
            result = package.remove(name)
            if not result.ok:
                error("Failed to remove " + name + ": " + result.stderr)
            removed.append(name)

    # Autoremove orphaned dependencies
    if len(removed) > 0:
        note("Cleaning up orphaned dependencies...")
        sudo("apt-get autoremove --yes")

    # Update package lists
    note("Updating package lists...")
    result = package.update()
    if not result.ok:
        error("Failed to update package lists: " + result.stderr)

    # Return state for next phase
    return {
        "conflicts_removed": removed,
        "package_lists_updated": True,
    }
