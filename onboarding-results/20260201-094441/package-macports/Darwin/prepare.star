# macports/Darwin/prepare.star - Prepare phase for MacPorts on macOS
#
# TRIBAL KNOWLEDGE:
# Xcode Command Line Tools are absolutely required. Many users skip this
# and then get cryptic build errors. We check early and fail fast.
#
# With Xcode 4+, the EULA must be accepted or builds will fail silently.
# This is the #1 cause of "MacPorts doesn't work" support tickets.

def prepare():
    """Check preconditions for MacPorts installation."""
    _check_command_line_tools()
    _check_xcode_license()
    _detect_migration_needs()
    return {"prepare": True}

def _check_command_line_tools():
    """Verify Xcode Command Line Tools are installed."""
    if not _command_line_tools_installed():
        print("Installing Xcode Command Line Tools...")
        shell.exec(
            "xcode-select --install",
            allowed_commands=["xcode-select"],
        )
        print("Please complete the Command Line Tools installation and run lore again.")
        fail("Xcode Command Line Tools installation initiated")

def _command_line_tools_installed():
    """Check if Command Line Tools are already installed."""
    result = shell.exec(
        "xcode-select -p",
        allowed_commands=["xcode-select"],
        check=False,
    )
    return result.returncode == 0

def _check_xcode_license():
    """Check and prompt for Xcode license acceptance."""
    # TRIBAL KNOWLEDGE:
    # xcodebuild -checkFirstLaunchStatus returns 0 if license accepted
    # Returns 69 if license needs acceptance
    result = shell.exec(
        "xcodebuild -checkFirstLaunchStatus",
        allowed_commands=["xcodebuild"],
        check=False,
    )
    
    if result.returncode == 69:
        print("Xcode license must be accepted before proceeding.")
        print("Please run: sudo xcodebuild -license accept")
        fail("Xcode license not accepted")

def _detect_migration_needs():
    """Check if existing MacPorts needs migration."""
    if not fs.exists("/opt/local/bin/port"):
        # No existing installation
        return
    
    # Check if this is a major OS upgrade scenario
    current_version = platform.version
    installed_for_version = _get_installed_macports_target_version()
    
    if installed_for_version and installed_for_version != current_version:
        print(f"MacPorts was installed for macOS {installed_for_version}")
        print(f"Current macOS version: {current_version}")
        print("This may require migration. Enable 'migration-mode' feature if needed.")

def _get_installed_macports_target_version():
    """Try to determine what macOS version current MacPorts was built for."""
    try:
        # Check macports.conf for any version-specific settings
        if fs.exists("/opt/local/etc/macports/macports.conf"):
            config = fs.read("/opt/local/etc/macports/macports.conf")
            # This is a heuristic - actual detection is complex
            return None  # Would need more sophisticated parsing
        return None
    except:
        return None

def rollback():
    """No rollback needed for prepare phase."""
    pass
