# macports/Darwin/prepare.star - Prepare phase for MacPorts on macOS
#
# TRIBAL KNOWLEDGE:
# MacPorts requires Xcode Command Line Tools and accepted license.
# After major macOS upgrades, existing MacPorts installations are incompatible
# and require migration or reinstallation.

def prepare():
    """Check preconditions for MacPorts installation."""
    _check_xcode_tools()
    _check_xcode_license()
    _check_os_compatibility()
    _warn_about_contamination()
    return {"prepare": True}

def _check_xcode_license():
    """Ensure Xcode license is accepted."""
    # TRIBAL KNOWLEDGE: Xcode 4+ requires explicit license acceptance
    # This is a common cause of MacPorts build failures
    result = shell.exec(
        "xcodebuild -checkFirstLaunchStatus",
        allowed_commands=["xcodebuild"],
    )
    if result.exit_code != 0:
        shell.exec(
            "sudo xcodebuild -license accept",
            allowed_commands=["xcodebuild"],
        )

def _check_xcode_tools():
    """Verify Command Line Tools are installed."""
    if not fs.exists("/usr/bin/xcode-select"):
        fail("Xcode Command Line Tools not found")
    
    result = shell.exec(
        "xcode-select -p",
        allowed_commands=["xcode-select"],
    )
    if result.exit_code != 0:
        fail("Command Line Tools not properly configured")

def _warn_about_contamination():
    """Check for potential /usr/local contamination."""
    # TRIBAL KNOWLEDGE: Software in /usr/local can break MacPorts builds
    # MacPorts uses /opt/local specifically to avoid this issue
    if fs.exists("/usr/local/bin") or fs.exists("/usr/local/lib"):
        print("WARNING: /usr/local software detected")
        print("This may interfere with MacPorts builds")
        print("Consider using 'sudo port -t install' for trace mode")

def _check_os_compatibility():
    """Warn about OS version compatibility."""
    # Check if this is a fresh OS and existing MacPorts needs migration
    if fs.exists("/opt/local/bin/port"):
        print("Existing MacPorts installation detected")
        print("After macOS upgrades, run 'sudo port migrate' or reinstall")

def rollback():
    """No rollback needed for prepare phase."""
    pass

