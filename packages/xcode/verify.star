# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# xcode/verify.star - Verify phase for Xcode IDE
#
# Verification confirms:
# 1. Xcode.app exists at expected path
# 2. xcodebuild -version returns valid output
# 3. Requested simulators are available
# 4. Developer tools are functional


def verify():
    """Verify Xcode installation and configuration."""

    state = lore.state()
    install_path = state.get("install_path", "/Applications/Xcode.app")

    results = {
        "xcode_path": False,
        "xcodebuild": False,
        "version": "",
        "simulators": {},
    }

    # Verify Xcode.app exists
    if fs.exists(install_path):
        results["xcode_path"] = True
        note("Xcode found at " + install_path)
    else:
        error("Xcode not found at " + install_path)

    # Verify xcodebuild works
    version_result = shell.exec(
        command = "xcodebuild -version",
        allowed_commands = ["xcodebuild"],
    )

    if version_result.ok:
        results["xcodebuild"] = True
        output = version_result.stdout.strip()
        note("xcodebuild: " + output.split("\n")[0])

        # Extract version
        for line in output.split("\n"):
            if line.startswith("Xcode"):
                results["version"] = line.replace("Xcode ", "")
                break
    else:
        error("xcodebuild failed: " + version_result.stderr)

    # Verify simulators if requested
    _verify_simulators(results)

    # Verify developer tools
    _verify_developer_tools(results)

    # Summary
    note("")
    note("Verification Summary:")
    note("  Xcode Version: " + results.get("version", "unknown"))
    note("  Path: " + install_path)

    if results.get("simulators"):
        note("  Simulators:")
        for sim, status in results["simulators"].items():
            status_str = "available" if status else "not found"
            note("    " + sim + ": " + status_str)

    state["verified"] = True
    state["verification"] = results

    return state


def _verify_simulators(results):
    """Verify requested simulators are available."""

    # Get list of available simulators
    list_result = shell.exec(
        command = "xcrun simctl list runtimes --json 2>/dev/null",
        allowed_commands = ["xcrun"],
    )

    available_runtimes = []
    if list_result.ok:
        # Parse JSON output to find available runtimes
        # Format: {"runtimes": [{"name": "iOS 17.2", ...}, ...]}
        output = list_result.stdout

        # Simple parsing - look for runtime names
        if "iOS" in output:
            available_runtimes.append("iOS")
        if "watchOS" in output:
            available_runtimes.append("watchOS")
        if "tvOS" in output:
            available_runtimes.append("tvOS")
        if "visionOS" in output or "xrOS" in output:
            available_runtimes.append("visionOS")

    # Check each requested simulator
    if package.feature("ios-simulator"):
        found = "iOS" in available_runtimes
        results["simulators"]["iOS"] = found
        if found:
            note("iOS Simulator: available")
        else:
            warn("iOS Simulator: not found (may need to download)")

    if package.feature("watchos-simulator"):
        found = "watchOS" in available_runtimes
        results["simulators"]["watchOS"] = found
        if found:
            note("watchOS Simulator: available")
        else:
            warn("watchOS Simulator: not found")

    if package.feature("tvos-simulator"):
        found = "tvOS" in available_runtimes
        results["simulators"]["tvOS"] = found
        if found:
            note("tvOS Simulator: available")
        else:
            warn("tvOS Simulator: not found")

    if package.feature("visionos-simulator"):
        found = "visionOS" in available_runtimes
        results["simulators"]["visionOS"] = found
        if found:
            note("visionOS Simulator: available")
        else:
            warn("visionOS Simulator: not found")


def _verify_developer_tools(results):
    """Verify developer tools are functional."""

    # Check xcode-select
    select_result = shell.exec(
        command = "xcode-select -p",
        allowed_commands = ["xcode-select"],
    )

    if select_result.ok:
        dev_path = select_result.stdout.strip()
        note("Developer path: " + dev_path)
        results["developer_path"] = dev_path
    else:
        warn("xcode-select not configured")

    # Check clang
    clang_result = shell.exec(
        command = "clang --version",
        allowed_commands = ["clang"],
    )

    if clang_result.ok:
        clang_version = clang_result.stdout.split("\n")[0]
        note("Compiler: " + clang_version)
        results["clang"] = True
    else:
        warn("clang not functional")
        results["clang"] = False

    # Check swift
    swift_result = shell.exec(
        command = "swift --version",
        allowed_commands = ["swift"],
    )

    if swift_result.ok:
        swift_version = swift_result.stdout.split("\n")[0]
        note("Swift: " + swift_version)
        results["swift"] = True
    else:
        warn("swift not functional")
        results["swift"] = False


def rollback():
    """Rollback verification on failure."""
    # Verification is read-only, nothing to rollback
    pass
