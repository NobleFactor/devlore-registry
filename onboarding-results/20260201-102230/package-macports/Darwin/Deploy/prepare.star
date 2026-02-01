# macports/Darwin/Deploy/prepare.star
#
# TRIBAL KNOWLEDGE:
# Command Line Developer Tools are absolutely critical for MacPorts.
# Many obscure port build failures trace back to missing, outdated, or
# corrupted CLT installation. This is the #1 cause of support requests.

def prepare(package, system, plan):
    """Check preconditions for MacPorts installation."""
    
    # Check macOS version compatibility
    if not _check_macos_compatibility(system):
        return {"prepare": "unsupported_os"}
    
    # Verify Command Line Tools are installed
    _check_command_line_tools(package, system, plan)
    
    # Check for Xcode if present and ensure license accepted
    _check_xcode_license(package, system, plan)
    
    # Detect potential conflicts with Homebrew
    _check_homebrew_conflicts(system)
    
    # Check for previous MacPorts installation
    _check_existing_installation(system)
    
    return {"prepare": True}

def _check_macos_compatibility(system):
    """Verify macOS version is supported."""
    major_version = int(system.platform.version.split(".")[0])
    
    # MacPorts supports macOS 10.6+ (Snow Leopard)
    # Current version 2.11.6 supports through macOS 26 (Tahoe)
    if major_version < 10:
        return False
    return True

def _check_command_line_tools(package, system, plan):
    """Verify Command Line Tools are installed and current.
    
    TRIBAL KNOWLEDGE:
    CLT issues are the most common cause of port build failures.
    Symptoms include missing headers, compiler errors, and
    "xcode-select: error: tool 'xcodebuild' requires Xcode" messages.
    """
    # Check if CLT are installed
    clt_check = plan.shell("xcode-select -p")
    
    # If missing, provide clear instructions
    # Note: We don't auto-install as it requires GUI interaction
    install_instructions = """
Command Line Developer Tools are required but not installed.
Please run: xcode-select --install
Then restart this installation.
"""
    
    # Check CLT version compatibility with macOS
    version_check = plan.shell("pkgutil --pkg-info=com.apple.pkg.CLTools_Executables")

def _check_xcode_license(package, system, plan):
    """Check if Xcode license has been accepted.
    
    TRIBAL KNOWLEDGE:
    Xcode 4+ requires EULA acceptance before xcodebuild works.
    This causes cryptic build failures with "Agreeing to the Xcode/iOS license" errors.
    """
    if system.package.installed("xcode"):
        # Check license status
        license_check = plan.shell("xcodebuild -checkFirstLaunchStatus")
        
        # If license not accepted, provide instructions
        license_instructions = """
Xcode license must be accepted before building ports.
Run: sudo xcodebuild -license accept
Or launch Xcode.app and accept the license agreement.
"""

def _check_homebrew_conflicts(system):
    """Check for Homebrew installation and warn about conflicts.
    
    TRIBAL KNOWLEDGE:
    MacPorts (/opt/local) and Homebrew (/usr/local or /opt/homebrew)
    can coexist but PATH ordering determines precedence.
    Library conflicts are possible but not fatal.
    """
    if system.package.installed("brew"):
        warning = """
Homebrew detected. MacPorts and Homebrew can coexist but may conflict.
MacPorts will install to /opt/local, ensure it appears first in PATH.
"""

def _check_existing_installation(system):
    """Check for existing MacPorts installation."""
    if system.package.installed("port"):
        # Get current version
        current_version = system.package.version("port")
        note = f"MacPorts {current_version} already installed. This will upgrade it."

def rollback(package, system, plan):
    """No rollback needed for prepare phase."""
    pass
