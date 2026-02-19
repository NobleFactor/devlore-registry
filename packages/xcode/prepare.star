# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# xcode/prepare.star - Prepare phase for Xcode IDE
#
# TRIBAL KNOWLEDGE:
# - Xcode requires significant disk space (~15-25GB installed)
# - Xcode version must match macOS version requirements
# - Multiple Xcode versions can coexist in /Applications
# - mas (Mac App Store CLI) enables headless installation
# - Without mas, user must install from App Store manually

# Xcode App Store ID
_XCODE_APP_ID = "497799835"

# Default installation path
_DEFAULT_PATH = "/Applications/Xcode.app"


def prepare():
    """Prepare the system for Xcode installation."""

    # Platform gate - Darwin only
    if platform.os != "darwin":
        error("Xcode is only supported on macOS (darwin), got: " + platform.os)

    # Get macOS version info
    macos_info = _detect_macos_version()
    note("Detected macOS " + macos_info["version"] + " (" + macos_info["codename"] + ")")

    # Check minimum macOS version (Xcode 16 requires macOS 14.5+)
    if not _version_at_least(macos_info["version"], "14.5"):
        warn("Xcode 16 requires macOS 14.5 (Sonoma) or later")
        warn("Older Xcode versions may be available for your macOS version")

    # Check available disk space (Xcode needs ~25GB)
    disk_space = _check_disk_space()
    if disk_space["available_gb"] < 30:
        warn("Low disk space: " + str(disk_space["available_gb"]) + "GB available")
        warn("Xcode installation requires approximately 25-30GB")

    # Check for mas (Mac App Store CLI)
    mas_available = _check_mas_available()
    if mas_available:
        note("mas (Mac App Store CLI) detected - headless installation available")
    else:
        warn("mas not found - manual App Store installation may be required")
        warn("Install mas with: brew install mas")

    # Detect existing Xcode installation
    install_path = package.setting("install_path", _DEFAULT_PATH)
    existing = _detect_existing_xcode(install_path)

    if existing["installed"]:
        note("Existing Xcode found: " + existing["version"] + " at " + existing["path"])

    # Check for Apple Silicon and Rosetta
    rosetta_status = _check_rosetta()
    if platform.arch == "arm64":
        if rosetta_status["installed"]:
            note("Rosetta 2 is installed")
        elif package.feature("rosetta"):
            note("Rosetta 2 will be installed for x86_64 simulator support")

    # Prepare state for install phase
    state = {
        "macos": macos_info,
        "disk_space": disk_space,
        "mas_available": mas_available,
        "existing": existing,
        "rosetta": rosetta_status,
        "install_path": install_path,
        "needs_install": not existing["installed"],
    }

    return state


def _detect_macos_version():
    """Detect macOS version information."""

    result = shell.exec(
        command = "sw_vers -productVersion",
        allowed_commands = ["sw_vers"],
    )

    if not result.ok:
        error("Failed to detect macOS version: " + result.stderr)

    version = result.stdout.strip()
    parts = version.split(".")
    major = int(parts[0]) if len(parts) > 0 else 0
    minor = int(parts[1]) if len(parts) > 1 else 0

    build_result = shell.exec(
        command = "sw_vers -buildVersion",
        allowed_commands = ["sw_vers"],
    )
    build = build_result.stdout.strip() if build_result.ok else ""

    codename = _macos_codename(major, minor)

    return {
        "version": version,
        "build": build,
        "codename": codename,
        "major": major,
        "minor": minor,
    }


def _macos_codename(major, minor):
    """Map macOS version to codename."""

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

    if major == 10:
        legacy = {
            15: "Catalina",
            14: "Mojave",
            13: "High Sierra",
        }
        return legacy.get(minor, "macOS 10." + str(minor))

    return "macOS " + str(major)


def _check_disk_space():
    """Check available disk space on boot volume."""

    result = shell.exec(
        command = "df -g / | tail -1 | awk '{print $4}'",
        allowed_commands = ["df", "tail", "awk"],
    )

    available_gb = 0
    if result.ok:
        try:
            available_gb = int(result.stdout.strip())
        except ValueError:
            available_gb = 0

    return {
        "available_gb": available_gb,
        "sufficient": available_gb >= 30,
    }


def _check_mas_available():
    """Check if mas (Mac App Store CLI) is available."""

    result = shell.exec(
        command = "which mas",
        allowed_commands = ["which"],
    )

    return result.ok and result.stdout.strip() != ""


def _detect_existing_xcode(install_path):
    """Detect existing Xcode installation."""

    result = {
        "installed": False,
        "path": "",
        "version": "",
        "build": "",
    }

    if not fs.exists(install_path):
        return result

    result["installed"] = True
    result["path"] = install_path

    # Get version from xcodebuild
    version_result = shell.exec(
        command = install_path + "/Contents/Developer/usr/bin/xcodebuild -version 2>/dev/null | head -1",
        allowed_commands = ["xcodebuild", "head"],
    )

    if version_result.ok:
        # Parse "Xcode 16.2"
        output = version_result.stdout.strip()
        if output.startswith("Xcode "):
            result["version"] = output.replace("Xcode ", "")

    return result


def _check_rosetta():
    """Check Rosetta 2 installation status on Apple Silicon."""

    if platform.arch != "arm64":
        return {"applicable": False, "installed": False}

    rosetta_path = "/Library/Apple/usr/share/rosetta"
    installed = fs.exists(rosetta_path)

    return {
        "applicable": True,
        "installed": installed,
    }


def _version_at_least(version, minimum):
    """Check if version meets minimum requirement."""

    def parse_version(v):
        parts = v.split(".")
        return [int(p) for p in parts if p.isdigit()]

    v = parse_version(version)
    m = parse_version(minimum)

    while len(v) < len(m):
        v.append(0)
    while len(m) < len(v):
        m.append(0)

    for i in range(len(v)):
        if v[i] > m[i]:
            return True
        if v[i] < m[i]:
            return False

    return True
