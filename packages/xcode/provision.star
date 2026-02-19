# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# xcode/provision.star - Provision phase for Xcode IDE
#
# TRIBAL KNOWLEDGE:
# - xcodebuild -license accept: accept license non-interactively
# - xcodebuild -runFirstLaunch: install MobileDevice packages, etc.
# - xcodebuild -downloadPlatform <platform>: download simulator runtimes
# - DevToolsSecurity -enable: allow debugging without password prompts
# - xcode-select -s: set active developer directory
#
# Post-install provisioning can take 10-30+ minutes for simulators
#
# Reference: https://developer.apple.com/documentation/xcode/downloading-and-installing-additional-xcode-components


def provision():
    """Provision Xcode after installation."""

    state = lore.state()
    install_path = state.get("install_path", "/Applications/Xcode.app")

    # Verify Xcode exists
    if not fs.exists(install_path):
        error("Xcode not found at " + install_path)

    # Set xcode-select if requested
    if package.feature("xcode-select"):
        _configure_xcode_select(install_path)

    # Accept license if requested
    if package.feature("accept-license"):
        _accept_license()

    # Run first launch if requested
    if package.feature("first-launch"):
        _run_first_launch()

    # Enable developer tools security if requested
    if package.feature("dev-tools-security"):
        _enable_dev_tools_security()

    # Download simulators
    _download_simulators()

    state["provisioned"] = True
    return state


def _configure_xcode_select(install_path):
    """Set this Xcode as the active developer directory."""

    developer_path = install_path + "/Contents/Developer"

    # Check current setting
    result = shell.exec(
        command = "xcode-select -p",
        allowed_commands = ["xcode-select"],
    )

    current = result.stdout.strip() if result.ok else ""

    if current == developer_path:
        note("xcode-select already configured for " + install_path)
        return

    note("Setting xcode-select to " + install_path)

    result = shell.exec(
        command = "xcode-select -s '" + developer_path + "'",
        allowed_commands = ["xcode-select"],
    )

    if not result.ok:
        warn("Failed to set xcode-select: " + result.stderr)
        warn("You may need to run: sudo xcode-select -s '" + developer_path + "'")


def _accept_license():
    """Accept Xcode license agreement."""

    note("Accepting Xcode license agreement...")

    result = shell.exec(
        command = "xcodebuild -license accept",
        allowed_commands = ["xcodebuild"],
    )

    if not result.ok:
        # Check if already accepted
        if "license has already been accepted" in result.stderr.lower():
            note("License already accepted")
            return

        warn("Failed to accept license: " + result.stderr)
        warn("You may need to run: sudo xcodebuild -license accept")
    else:
        note("License accepted")


def _run_first_launch():
    """Run first launch to install additional components.

    This installs packages like:
    - MobileDevice.pkg
    - MobileDeviceDevelopment.pkg
    - XcodeSystemResources.pkg
    """

    note("Installing additional Xcode components...")
    note("This may take a few minutes...")

    result = shell.exec(
        command = "xcodebuild -runFirstLaunch",
        allowed_commands = ["xcodebuild"],
    )

    if not result.ok:
        # Check if already done
        if "already" in result.stderr.lower() or "up to date" in result.stderr.lower():
            note("Additional components already installed")
            return

        warn("Failed to install additional components: " + result.stderr)
        warn("You may need to run: sudo xcodebuild -runFirstLaunch")
    else:
        note("Additional components installed")


def _enable_dev_tools_security():
    """Enable Developer Tools security.

    This allows debugging without repeated password prompts.
    """

    note("Enabling Developer Tools security...")

    result = shell.exec(
        command = "DevToolsSecurity -enable",
        allowed_commands = ["DevToolsSecurity"],
    )

    if not result.ok:
        # Check if already enabled
        check_result = shell.exec(
            command = "DevToolsSecurity -status",
            allowed_commands = ["DevToolsSecurity"],
        )

        if check_result.ok and "enabled" in check_result.stdout.lower():
            note("Developer Tools security already enabled")
            return

        warn("Failed to enable Developer Tools security: " + result.stderr)
        warn("You may need to run: sudo DevToolsSecurity -enable")
    else:
        note("Developer Tools security enabled")


def _download_simulators():
    """Download simulator runtimes based on enabled features."""

    simulators = []

    if package.feature("ios-simulator"):
        simulators.append(("iOS", package.setting("simulator_ios_version", "")))

    if package.feature("watchos-simulator"):
        simulators.append(("watchOS", ""))

    if package.feature("tvos-simulator"):
        simulators.append(("tvOS", ""))

    if package.feature("visionos-simulator"):
        simulators.append(("visionOS", ""))

    if not simulators:
        note("No simulators requested")
        return

    for platform_name, version in simulators:
        _download_simulator(platform_name, version)


def _download_simulator(platform_name, version):
    """Download a specific simulator runtime.

    Args:
        platform_name: iOS, watchOS, tvOS, or visionOS
        version: Specific version or empty for latest
    """

    note("Downloading " + platform_name + " Simulator...")
    note("This may take several minutes (2-5GB download)...")

    # Build command
    cmd = "xcodebuild -downloadPlatform " + platform_name

    if version:
        cmd += " -buildVersion " + version

    result = shell.exec(
        command = cmd,
        allowed_commands = ["xcodebuild"],
        # Allow up to 30 minutes for download
    )

    if not result.ok:
        # Check for common issues
        stderr = result.stderr.lower()

        if "already installed" in stderr or "already downloaded" in stderr:
            note(platform_name + " Simulator already installed")
            return

        if "not found" in stderr or "unavailable" in stderr:
            warn(platform_name + " Simulator not available for this Xcode version")
            return

        if "disk space" in stderr:
            warn("Insufficient disk space for " + platform_name + " Simulator")
            return

        warn("Failed to download " + platform_name + " Simulator: " + result.stderr)
    else:
        note(platform_name + " Simulator downloaded successfully")
