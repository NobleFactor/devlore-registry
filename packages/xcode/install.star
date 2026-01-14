# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# xcode/install.star - Install phase for Xcode IDE
#
# TRIBAL KNOWLEDGE:
# - Xcode is distributed via Mac App Store (ID: 497799835)
# - mas (Mac App Store CLI) enables headless installation: mas install 497799835
# - Without mas, user must install manually from App Store
# - Download is ~10-12GB, installed size ~25GB
# - Installation can take 30+ minutes depending on connection
# - Apple Developer portal also offers direct downloads (requires auth)

# Xcode App Store ID
_XCODE_APP_ID = "497799835"


def install():
    """Install Xcode IDE."""

    state = lore.state()

    # Check if already installed
    existing = state.get("existing", {})
    if existing.get("installed", False) and not package.setting("force_reinstall", "false") == "true":
        note("Xcode already installed at " + existing.get("path", ""))
        return state

    # Install Rosetta if requested on Apple Silicon
    if platform.arch == "arm64" and package.feature("rosetta"):
        rosetta = state.get("rosetta", {})
        if not rosetta.get("installed", False):
            _install_rosetta()

    # Try mas installation if available
    if state.get("mas_available", False):
        _install_via_mas()
    else:
        # Guide manual installation
        _guide_manual_installation()

    # Update state
    state["installed"] = True
    state["method"] = "mas" if state.get("mas_available", False) else "manual"

    return state


def _install_rosetta():
    """Install Rosetta 2 for x86_64 binary compatibility on Apple Silicon."""

    note("Installing Rosetta 2 for x86_64 simulator support...")

    result = shell.exec(
        command = "softwareupdate --install-rosetta --agree-to-license",
        allowed_commands = ["softwareupdate"],
    )

    if not result.ok:
        warn("Failed to install Rosetta 2: " + result.stderr)
        warn("Some x86_64 simulators may not work correctly")
    else:
        note("Rosetta 2 installed successfully")


def _install_via_mas():
    """Install Xcode via Mac App Store CLI (mas)."""

    note("Installing Xcode via Mac App Store...")
    note("This download is approximately 10-12GB and may take 30+ minutes")

    # Check if signed in to App Store
    signin_result = shell.exec(
        command = "mas account",
        allowed_commands = ["mas"],
    )

    if not signin_result.ok or "Not signed in" in signin_result.stdout:
        if package.setting("mas_signin", "true") == "true":
            warn("Not signed in to Mac App Store")
            warn("Please sign in via App Store.app or run: mas signin your@email.com")
            error("Mac App Store authentication required for Xcode installation")
        else:
            error("Not signed in to Mac App Store and mas_signin=false")

    note("Signed in as: " + signin_result.stdout.strip())

    # Install Xcode
    result = shell.exec(
        command = "mas install " + _XCODE_APP_ID,
        allowed_commands = ["mas"],
        # Allow up to 60 minutes for download
    )

    if not result.ok:
        stderr = result.stderr.lower()

        if "already installed" in stderr or "already purchased" in stderr:
            note("Xcode is already installed via App Store")
            return

        if "sign in" in stderr:
            error("Mac App Store sign-in required: " + result.stderr)

        error("Failed to install Xcode via mas: " + result.stderr)

    note("Xcode installed successfully via Mac App Store")


def _guide_manual_installation():
    """Guide user through manual Xcode installation."""

    warn("Automated installation not available (mas not found)")
    warn("")
    warn("Please install Xcode manually:")
    warn("  1. Open App Store.app")
    warn("  2. Search for 'Xcode'")
    warn("  3. Click 'Get' or 'Install'")
    warn("  4. Wait for download and installation (~10-12GB)")
    warn("")
    warn("Alternatively, download from Apple Developer portal:")
    warn("  https://developer.apple.com/download/applications/")
    warn("")
    warn("After installation, re-run this deployment to configure Xcode")

    # Check periodically if user installed manually
    install_path = lore.state().get("install_path", "/Applications/Xcode.app")

    if fs.exists(install_path):
        note("Xcode detected at " + install_path)
    else:
        error("Xcode not found at " + install_path + " - please install manually and retry")


def rollback():
    """Rollback installation on failure."""

    note("Rolling back Xcode installation...")

    # We don't automatically remove Xcode on rollback
    # as the download is too large and user may want to keep it
    warn("Xcode installation may be incomplete")
    warn("To remove Xcode completely, drag /Applications/Xcode.app to Trash")

    note("Rollback complete")


def decommission():
    """Decommission (uninstall) Xcode.

    This removes Xcode and associated data.
    """

    note("Decommissioning Xcode...")

    install_path = lore.state().get("install_path", "/Applications/Xcode.app")

    # Remove Xcode.app
    if fs.exists(install_path):
        note("Removing " + install_path + "...")
        result = shell.exec(
            command = "rm -rf '" + install_path + "'",
            allowed_commands = ["rm"],
        )

        if not result.ok:
            error("Failed to remove Xcode: " + result.stderr)

        note("Removed Xcode.app")

    # Remove derived data
    derived_data = platform.home + "/Library/Developer/Xcode/DerivedData"
    if fs.exists(derived_data):
        note("Removing derived data...")
        shell.exec(
            command = "rm -rf '" + derived_data + "'",
            allowed_commands = ["rm"],
        )

    # Remove caches
    caches = platform.home + "/Library/Caches/com.apple.dt.Xcode"
    if fs.exists(caches):
        note("Removing caches...")
        shell.exec(
            command = "rm -rf '" + caches + "'",
            allowed_commands = ["rm"],
        )

    # Reset xcode-select if pointing to removed Xcode
    select_result = shell.exec(
        command = "xcode-select -p",
        allowed_commands = ["xcode-select"],
    )

    if select_result.ok and install_path in select_result.stdout:
        shell.exec(
            command = "xcode-select --reset",
            allowed_commands = ["xcode-select"],
        )

    note("Xcode decommissioned")

    return {
        "decommissioned": True,
    }
