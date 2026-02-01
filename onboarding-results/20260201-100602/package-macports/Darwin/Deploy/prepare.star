# macports/Darwin/Deploy/prepare.star - Prepare phase for MacPorts
#
# TRIBAL KNOWLEDGE:
# Software in /usr/local and /Library/Frameworks can interfere with MacPorts
# builds, causing mysterious compilation failures. This is the #1 cause of
# "MacPorts doesn't work" complaints. We check for common interference sources
# and warn the user.

def prepare():
    """Check preconditions and detect potential conflicts."""
    _check_macos_version()
    _check_xcode_tools()
    _check_interference_sources()
    _check_existing_macports()
    return {"prepare": True}

def _check_macos_version():
    """Ensure supported macOS version."""
    if not platform.version_gte("10.5"):
        fail("MacPorts requires macOS 10.5 (Leopard) or later")

def _check_xcode_tools():
    """Verify Xcode Command Line Tools are available."""
    if not fs.exists("/usr/bin/xcode-select"):
        fail("Xcode Command Line Tools not found. Run: xcode-select --install")
    
    # Check if tools are properly installed
    result = shell.exec("xcode-select -p", allowed_commands=["xcode-select"])
    if not result.success:
        fail("Xcode Command Line Tools not properly installed")

def _check_interference_sources():
    """Check for software that can interfere with MacPorts builds."""
    interference_paths = [
        "/usr/local/bin",
        "/usr/local/lib", 
        "/Library/Frameworks"
    ]
    
    found_interference = []
    for path in interference_paths:
        if fs.exists(path):
            # Check if directory is non-empty
            result = shell.exec(f"ls -A {path}", allowed_commands=["ls"])
            if result.success and result.stdout.strip():
                found_interference.append(path)
    
    if found_interference:
        print(f"WARNING: Found software in interference-prone locations: {found_interference}")
        print("This may cause MacPorts build failures. Consider moving software or")
        print("temporarily renaming these directories during MacPorts operations.")

def _check_existing_macports():
    """Check for existing MacPorts installation."""
    if fs.exists("/opt/local/bin/port"):
        result = shell.exec("port version", allowed_commands=["port"])
        if result.success:
            print(f"Found existing MacPorts: {result.stdout.strip()}")
            print("This installation will upgrade the existing MacPorts base.")

def rollback():
    """No rollback needed for prepare phase."""
    pass
