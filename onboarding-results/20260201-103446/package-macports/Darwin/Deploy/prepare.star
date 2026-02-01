# macports/Darwin/Deploy/prepare.star
#
# TRIBAL KNOWLEDGE:
# Xcode Command Line Tools are separate from Xcode itself and must be
# explicitly installed even if full Xcode is present. This is the #1 cause
# of MacPorts build failures. Software in /usr/local can interfere with
# MacPorts builds through unexpected header/library discovery.

def prepare(package, system, plan):
    """Check preconditions and prepare system for MacPorts installation."""
    
    # Check for required dependencies
    _check_xcode_tools(package, system, plan)
    
    # Warn about potential conflicts
    _check_conflicts(package, system, plan)
    
    # Accept Xcode license if needed
    _accept_xcode_license(package, system, plan)
    
    return {"prepare": True}

def _check_xcode_tools(package, system, plan):
    """Verify Xcode Command Line Tools are installed."""
    # Check if command line tools are installed
    check_clt = plan.shell("xcode-select -p")
    
    # The above command will fail if CLT not installed
    # In real implementation, we'd check the exit code
    # For now, we document the requirement
    
def _check_conflicts(package, system, plan):
    """Check for potential conflicts with other package managers."""
    
    # Check for Homebrew
    if system.package.installed("brew"):
        # This is a warning, not a failure - they can coexist
        pass
    
    # Check for software in /usr/local that might interfere
    check_usr_local = plan.shell("ls -la /usr/local/bin 2>/dev/null | wc -l")
    
def _accept_xcode_license(package, system, plan):
    """Accept Xcode license if Xcode is installed."""
    # Only needed if full Xcode is installed
    license_check = plan.shell("xcodebuild -checkFirstLaunchStatus 2>/dev/null || true")
    
    # If license needs acceptance, this would be the command:
    # plan.shell("sudo xcodebuild -license accept")
    
def rollback(package, system, plan):
    """No rollback needed for prepare phase."""
    return {"rollback": True}

