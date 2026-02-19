# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# xcode-clt/prepare.star - Prepare phase for Xcode Command Line Tools
#
# TRIBAL KNOWLEDGE:
# - macOS version determines which CLT version you can install
# - CLT can exist at /Library/Developer/CommandLineTools (standalone)
#   or inside Xcode.app at /Applications/Xcode.app/Contents/Developer
# - xcode-select -p tells you which is active
# - pkgutil receipts can be stale after macOS upgrades
# - Apple Silicon Macs may need Rosetta for some legacy tools

def prepare():
    """Prepare the system for Xcode Command Line Tools installation."""

    # Platform gate - Darwin only
    if platform.os != "darwin":
        error("xcode-clt is only supported on macOS (darwin), got: " + platform.os)

    # Get macOS version info
    macos_info = _detect_macos_version()
    note("Detected macOS " + macos_info["version"] + " (" + macos_info["codename"] + ")")

    # Check minimum macOS version (CLT requires at least 10.9 Mavericks)
    if not _version_at_least(macos_info["version"], "10.9"):
        error("Xcode Command Line Tools require macOS 10.9 (Mavericks) or later")

    # Detect existing installations
    existing = _detect_existing_installation()

    # Check if we need to do anything
    force = package.setting("force_reinstall", "false") == "true"
    allow_xcode = package.setting("allow_xcode_fallback", "true") == "true"

    if existing["has_clt"] and not force:
        if existing["source"] == "xcode" and not allow_xcode:
            note("Full Xcode detected but allow_xcode_fallback=false; will install standalone CLT")
        elif existing["version_ok"]:
            # Already installed and version matches
            success("Xcode Command Line Tools already installed: " + existing["version"], {
                "already_installed": True,
                "source": existing["source"],
                "path": existing["path"],
                "version": existing["version"],
                "macos": macos_info,
            })

    # Check for Apple Silicon and Rosetta
    rosetta_status = _check_rosetta()
    if platform.arch == "arm64" and package.feature("rosetta"):
        if not rosetta_status["installed"]:
            note("Rosetta 2 will be installed for x86_64 compatibility")

    # Prepare state for install phase
    state = {
        "macos": macos_info,
        "existing": existing,
        "rosetta": rosetta_status,
        "needs_install": not existing["has_clt"] or force or not existing["version_ok"],
        "needs_removal": existing["has_clt"] and (force or not existing["version_ok"]),
    }

    if state["needs_removal"]:
        note("Existing CLT will be removed before reinstallation")

    if state["needs_install"]:
        note("Xcode Command Line Tools will be installed via softwareupdate")

    return state


def _detect_macos_version():
    """Detect macOS version information.

    Returns:
        dict: {version: str, build: str, codename: str, major: int, minor: int}
    """

    # Use sw_vers to get version info
    result = shell.exec(
        command = "sw_vers -productVersion",
        allowed_commands = ["sw_vers"],
    )

    if not result.ok:
        error("Failed to detect macOS version: " + result.stderr)

    version = result.stdout.strip()

    # Parse major.minor
    parts = version.split(".")
    major = int(parts[0]) if len(parts) > 0 else 0
    minor = int(parts[1]) if len(parts) > 1 else 0

    # Get build number
    build_result = shell.exec(
        command = "sw_vers -buildVersion",
        allowed_commands = ["sw_vers"],
    )
    build = build_result.stdout.strip() if build_result.ok else ""

    # Map version to codename
    codename = _macos_codename(major, minor)

    return {
        "version": version,
        "build": build,
        "codename": codename,
        "major": major,
        "minor": minor,
    }


def _macos_codename(major, minor):
    """Map macOS version to codename.

    Args:
        major: Major version number
        minor: Minor version number

    Returns:
        str: macOS codename
    """

    # Modern macOS versions (11+)
    codenames = {
        26: "Tahoe",
        15: "Sequoia",
        14: "Sonoma",
        13: "Ventura",
        12: "Monterey",
        11: "Big Sur",
    }

    if major in codenames:
        return codenames[major]

    # Legacy macOS 10.x versions
    if major == 10:
        legacy = {
            15: "Catalina",
            14: "Mojave",
            13: "High Sierra",
            12: "Sierra",
            11: "El Capitan",
            10: "Yosemite",
            9: "Mavericks",
        }
        return legacy.get(minor, "macOS 10." + str(minor))

    return "macOS " + str(major)


def _detect_existing_installation():
    """Detect existing Xcode Command Line Tools installation.

    TRIBAL KNOWLEDGE:
    - xcode-select -p returns the active developer directory
    - /Library/Developer/CommandLineTools = standalone CLT
    - /Applications/Xcode.app/Contents/Developer = full Xcode
    - pkgutil receipts may be stale but the tools still work

    Returns:
        dict: {has_clt: bool, source: str, path: str, version: str, version_ok: bool}
    """

    result = {
        "has_clt": False,
        "source": "",
        "path": "",
        "version": "",
        "version_ok": False,
    }

    # Check xcode-select path
    select_result = shell.exec(
        command = "xcode-select -p",
        allowed_commands = ["xcode-select"],
    )

    if not select_result.ok:
        # xcode-select returns error if no tools installed
        note("No developer tools path configured")
        return result

    dev_path = select_result.stdout.strip()
    result["path"] = dev_path

    if "/CommandLineTools" in dev_path:
        result["source"] = "standalone"
        result["has_clt"] = fs.exists(dev_path)
    elif "/Xcode.app" in dev_path:
        result["source"] = "xcode"
        result["has_clt"] = fs.exists(dev_path)
    else:
        # Unknown developer path
        result["source"] = "unknown"
        result["has_clt"] = fs.exists(dev_path)

    if not result["has_clt"]:
        note("Developer path configured but directory missing: " + dev_path)
        return result

    # Try to get version from pkgutil (may be stale)
    result["version"] = _get_clt_version()

    # Check if clang actually works (more reliable than pkgutil)
    clang_result = shell.exec(
        command = "clang --version",
        allowed_commands = ["clang"],
    )

    if clang_result.ok:
        result["has_clt"] = True
        # Parse Apple clang version from output
        for line in clang_result.stdout.split("\n"):
            if "Apple clang version" in line:
                # Extract version: "Apple clang version 15.0.0 (clang-1500.0.40.1)"
                parts = line.split("Apple clang version ")
                if len(parts) > 1:
                    result["version"] = parts[1].split(" ")[0]
                break

        # Version is OK if we got a version and clang works
        result["version_ok"] = result["version"] != ""
    else:
        # clang doesn't work - tools may be broken
        warn("Developer tools path exists but clang is not functional")
        result["has_clt"] = False

    return result


def _get_clt_version():
    """Get CLT version from pkgutil receipt.

    Note: This can fail after macOS upgrades even if tools work.

    Returns:
        str: Version string or empty if not found
    """

    # Try CLTools_Executables receipt first
    result = shell.exec(
        command = "pkgutil --pkg-info=com.apple.pkg.CLTools_Executables 2>/dev/null | grep version | cut -d ' ' -f 2",
        allowed_commands = ["pkgutil", "grep", "cut"],
    )

    if result.ok and result.stdout.strip():
        return result.stdout.strip()

    # Fallback: try CLTools_macOS_SDK
    result = shell.exec(
        command = "pkgutil --pkg-info=com.apple.pkg.CLTools_macOS_SDK 2>/dev/null | grep version | cut -d ' ' -f 2",
        allowed_commands = ["pkgutil", "grep", "cut"],
    )

    if result.ok and result.stdout.strip():
        return result.stdout.strip()

    return ""


def _check_rosetta():
    """Check Rosetta 2 installation status on Apple Silicon.

    Returns:
        dict: {applicable: bool, installed: bool}
    """

    # Rosetta only applies to Apple Silicon
    if platform.arch != "arm64":
        return {"applicable": False, "installed": False}

    # Check if Rosetta is installed by looking for the runtime
    # /Library/Apple/usr/share/rosetta exists when Rosetta is installed
    rosetta_path = "/Library/Apple/usr/share/rosetta"
    installed = fs.exists(rosetta_path)

    # Alternative check: try to run arch -x86_64
    if not installed:
        result = shell.exec(
            command = "arch -x86_64 /usr/bin/true 2>/dev/null",
            allowed_commands = ["arch"],
        )
        installed = result.ok

    return {
        "applicable": True,
        "installed": installed,
    }


def _version_at_least(version, minimum):
    """Check if version meets minimum requirement.

    Args:
        version: Version string (e.g., "14.2.1")
        minimum: Minimum version string (e.g., "10.9")

    Returns:
        bool: True if version >= minimum
    """

    def parse_version(v):
        parts = v.split(".")
        return [int(p) for p in parts if p.isdigit()]

    v = parse_version(version)
    m = parse_version(minimum)

    # Pad to same length
    while len(v) < len(m):
        v.append(0)
    while len(m) < len(v):
        m.append(0)

    for i in range(len(v)):
        if v[i] > m[i]:
            return True
        if v[i] < m[i]:
            return False

    return True  # Equal
