# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# astro/prepare.star - Prepare phase for Astro installation
#
# TRIBAL KNOWLEDGE:
# - Node.js v18.20.8+, v20.3.0+, or v22+ required
# - v19 and v21 are NOT supported (odd-numbered releases)

def prepare():
    """Prepare the system for Astro installation."""

    # Check Node.js is installed
    node_path = fs.which("node")
    if not node_path:
        error("Node.js is required but not found. Install nodejs first.")

    # Verify Node.js version meets Astro requirements
    result = shell.exec("node --version")
    if not result.ok:
        error("Could not determine Node.js version")

    version_str = result.stdout.strip()
    note("Found Node.js " + version_str)

    if not _version_supported(version_str):
        error("Astro requires Node.js v18.20.8+, v20.3.0+, or v22+. " +
              "Found: " + version_str + ". " +
              "Note: v19 and v21 are NOT supported.")

    # Verify package manager is available
    pm = package.setting("package_manager", "npm")
    pm_path = fs.which(pm)
    if not pm_path:
        error(pm + " not found in PATH")

    result = shell.exec(pm + " --version")
    if result.ok:
        note(pm + " version: " + result.stdout.strip())

    return {
        "node_version": version_str,
        "package_manager": pm,
    }

def _version_supported(version_str):
    """Check if Node.js version meets Astro requirements."""

    # Parse "v18.20.8" format
    if not version_str.startswith("v"):
        return False

    parts = version_str[1:].split(".")
    if len(parts) < 2:
        return False

    major = int(parts[0])
    minor = int(parts[1])
    patch = int(parts[2].split("-")[0]) if len(parts) > 2 else 0

    # v18.20.8+ required
    if major == 18:
        return minor > 20 or (minor == 20 and patch >= 8)

    # v19 NOT supported
    if major == 19:
        return False

    # v20.3.0+ required
    if major == 20:
        return minor >= 3

    # v21 NOT supported
    if major == 21:
        return False

    # v22+ supported
    return major >= 22
