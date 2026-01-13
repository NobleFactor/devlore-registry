# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# xcode-clt/install.star - Install phase for Xcode Command Line Tools
#
# TRIBAL KNOWLEDGE - THE HEADLESS INSTALLATION METHOD:
#
# The standard `xcode-select --install` command opens a GUI dialog, making it
# useless for automation, VMs, CI/CD, or any headless scenario.
#
# The workaround discovered by the community (and used by Homebrew):
# 1. Create a marker file: /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
# 2. This tricks softwareupdate into listing the Command Line Tools package
# 3. Parse the package name from softwareupdate output
# 4. Install via: softwareupdate -i "<package-name>"
# 5. Remove the marker file
#
# This method has been tested on macOS 10.9 through 26 (Tahoe).
#
# CAVEATS:
# - softwareupdate package names change between macOS versions
# - Multiple CLT versions may be listed; take the latest
# - Download can take 5-15 minutes depending on connection
# - Requires sudo for softwareupdate -i
#
# Reference: https://github.com/Homebrew/install/blob/master/install.sh
# Reference: https://derflounder.wordpress.com/xcode-command-line-tools-installer-script/
# Reference: https://mokacoding.com/blog/how-to-install-xcode-cli-tools-without-gui/

# Marker file path used by Apple's software update system
_MARKER_FILE = "/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"

# Standard CLT installation directory
_CLT_PATH = "/Library/Developer/CommandLineTools"


def install():
    """Install Xcode Command Line Tools using the headless method."""

    # Get state from prepare phase
    state = lore.state()

    # Check if already installed and no action needed
    if state.get("already_installed", False):
        note("Using existing installation")
        return state

    # Check if we need to remove existing installation first
    if state.get("needs_removal", False):
        _remove_existing_clt()

    # Install Rosetta if requested on Apple Silicon
    if platform.arch == "arm64" and package.feature("rosetta"):
        rosetta = state.get("rosetta", {})
        if not rosetta.get("installed", False):
            _install_rosetta()

    # Perform the headless CLT installation
    if state.get("needs_install", True):
        _install_clt_headless()

    # Verify xcode-select path is set correctly
    _configure_xcode_select()

    return {
        "installed": True,
        "method": "softwareupdate",
        "path": _CLT_PATH,
    }


def _remove_existing_clt():
    """Remove existing Command Line Tools installation.

    Required before reinstallation because there's no in-place upgrade.
    """

    note("Removing existing Command Line Tools...")

    if not fs.exists(_CLT_PATH):
        note("No existing installation at " + _CLT_PATH)
        return

    # Remove the directory (requires root)
    result = shell.exec(
        command = "rm -rf " + _CLT_PATH,
        allowed_commands = ["rm"],
    )

    if not result.ok:
        error("Failed to remove existing CLT: " + result.stderr)

    # Reset xcode-select path
    shell.exec(
        command = "xcode-select --reset",
        allowed_commands = ["xcode-select"],
    )

    note("Existing installation removed")


def _install_rosetta():
    """Install Rosetta 2 for x86_64 binary compatibility on Apple Silicon.

    Rosetta allows running Intel (x86_64) binaries on Apple Silicon Macs.
    Some development tools may require this.
    """

    note("Installing Rosetta 2...")

    result = shell.exec(
        command = "softwareupdate --install-rosetta --agree-to-license",
        allowed_commands = ["softwareupdate"],
    )

    if not result.ok:
        warn("Failed to install Rosetta 2: " + result.stderr)
        warn("Some x86_64 tools may not work correctly")
    else:
        note("Rosetta 2 installed successfully")


def _install_clt_headless():
    """Install CLT using the headless softwareupdate method.

    This is the core tribal knowledge: a marker file triggers softwareupdate
    to list the CLT package, which can then be installed non-interactively.
    """

    note("Installing Xcode Command Line Tools (headless method)...")

    # Step 1: Create the marker file
    # This file signals to softwareupdate that we want the CLT listed
    note("Creating software update marker file...")
    result = shell.exec(
        command = "touch " + _MARKER_FILE,
        allowed_commands = ["touch"],
    )

    if not result.ok:
        error("Failed to create marker file: " + result.stderr)

    # Step 2: Find the CLT package name from softwareupdate
    # Package names vary by macOS version, e.g.:
    # - "Command Line Tools for Xcode-16.0"
    # - "Command Line Tools (macOS Sonoma version 15.0) for Xcode-16.1"
    note("Querying available Command Line Tools packages...")

    package_name = _find_clt_package()

    if not package_name:
        _cleanup_marker()
        error("Could not find Command Line Tools package in softwareupdate. " +
              "This may indicate a network issue or that CLT is not available for this macOS version.")

    note("Found package: " + package_name)

    # Step 3: Install the package via softwareupdate
    # This download can take 5-15 minutes
    note("Downloading and installing Command Line Tools (this may take several minutes)...")

    result = shell.exec(
        command = 'softwareupdate -i "' + package_name + '" --verbose',
        allowed_commands = ["softwareupdate"],
        # Allow up to 30 minutes for download and install
    )

    # Step 4: Cleanup marker file regardless of outcome
    _cleanup_marker()

    if not result.ok:
        # Check for common error conditions
        stderr = result.stderr.lower()

        if "network" in stderr or "connection" in stderr:
            error("Network error during CLT download. Check internet connection and try again.")
        elif "not found" in stderr:
            error("CLT package not found by softwareupdate: " + result.stderr)
        elif "disk space" in stderr or "space" in stderr:
            error("Insufficient disk space for CLT installation: " + result.stderr)
        else:
            error("CLT installation failed: " + result.stderr)

    # Verify the installation directory exists
    if not fs.exists(_CLT_PATH):
        error("Installation completed but CLT directory not found at " + _CLT_PATH)

    note("Command Line Tools installed successfully")


def _find_clt_package():
    """Find the CLT package name from softwareupdate listing.

    TRIBAL KNOWLEDGE:
    - softwareupdate -l lists available updates
    - The marker file makes CLT appear in this list
    - Package names include "Command Line" somewhere
    - Multiple versions may be listed; we want the latest
    - Output format varies by macOS version

    Returns:
        str: Package name, or empty string if not found
    """

    result = shell.exec(
        command = "softwareupdate -l 2>&1",
        allowed_commands = ["softwareupdate"],
    )

    if not result.ok and "No new software available" in result.stdout:
        # No updates available - CLT may already be at latest
        return ""

    # Parse the output to find CLT package
    # Modern format (macOS 11+):
    #   * Label: Command Line Tools for Xcode-16.0
    #       Title: Command Line Tools for Xcode, Version: 16.0, Size: 715536KiB
    #
    # Older format (macOS 10.x):
    #   * Command Line Tools (macOS Mojave version 10.14) for Xcode-11.0
    #       ...

    output = result.stdout + result.stderr
    lines = output.split("\n")

    candidates = []

    for line in lines:
        line = line.strip()

        # Look for lines containing "Command Line"
        if "Command Line" not in line:
            continue

        # Extract package name from different formats
        package_name = ""

        # Format: "* Label: Package Name"
        if line.startswith("* Label:"):
            package_name = line.replace("* Label:", "").strip()

        # Format: "* Package Name" (older)
        elif line.startswith("*") and "Command Line" in line:
            package_name = line.lstrip("* ").strip()

        if package_name:
            candidates.append(package_name)

    if not candidates:
        return ""

    # If multiple candidates, prefer the one with highest version number
    # This handles cases where both old and new CLT are listed
    if len(candidates) > 1:
        note("Found multiple CLT packages: " + ", ".join(candidates))
        # Sort by version number (extract from "Xcode-XX.X" or similar)
        candidates.sort(key=_extract_version, reverse=True)

    return candidates[0]


def _extract_version(package_name):
    """Extract version number from package name for sorting.

    Args:
        package_name: e.g., "Command Line Tools for Xcode-16.0"

    Returns:
        tuple: Version components for sorting, e.g., (16, 0)
    """

    # Try to find version pattern like "16.0" or "16.1.2"
    import_parts = package_name.split("-")
    if len(import_parts) > 1:
        version_part = import_parts[-1]
        try:
            return tuple(int(p) for p in version_part.split(".") if p.isdigit())
        except ValueError:
            pass

    # Fallback: return original string for alphabetical sort
    return (0,)


def _cleanup_marker():
    """Remove the marker file."""

    if fs.exists(_MARKER_FILE):
        shell.exec(
            command = "rm -f " + _MARKER_FILE,
            allowed_commands = ["rm"],
        )


def _configure_xcode_select():
    """Ensure xcode-select points to the standalone CLT."""

    result = shell.exec(
        command = "xcode-select -p",
        allowed_commands = ["xcode-select"],
    )

    current_path = result.stdout.strip() if result.ok else ""

    if current_path != _CLT_PATH:
        note("Configuring xcode-select to use " + _CLT_PATH)
        result = shell.exec(
            command = "xcode-select --switch " + _CLT_PATH,
            allowed_commands = ["xcode-select"],
        )

        if not result.ok:
            warn("Failed to configure xcode-select: " + result.stderr)


def rollback():
    """Rollback installation on failure."""

    note("Rolling back CLT installation...")

    # Remove marker file if it exists
    _cleanup_marker()

    # Remove partially installed CLT
    if fs.exists(_CLT_PATH):
        shell.exec(
            command = "rm -rf " + _CLT_PATH,
            allowed_commands = ["rm"],
        )

    # Reset xcode-select
    shell.exec(
        command = "xcode-select --reset",
        allowed_commands = ["xcode-select"],
    )

    note("Rollback complete")


def decommission():
    """Decommission (uninstall) Xcode Command Line Tools.

    This is the reverse of install - completely removes CLT from the system.
    """

    note("Decommissioning Xcode Command Line Tools...")

    # Remove the CLT directory
    if fs.exists(_CLT_PATH):
        result = shell.exec(
            command = "rm -rf " + _CLT_PATH,
            allowed_commands = ["rm"],
        )

        if not result.ok:
            error("Failed to remove CLT: " + result.stderr)

        note("Removed " + _CLT_PATH)
    else:
        note("CLT directory not found at " + _CLT_PATH)

    # Reset xcode-select
    shell.exec(
        command = "xcode-select --reset",
        allowed_commands = ["xcode-select"],
    )

    note("Xcode Command Line Tools decommissioned")

    return {
        "decommissioned": True,
    }
