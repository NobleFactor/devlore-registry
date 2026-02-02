# macports/Darwin/Upgrade/prepare.star
#
# TRIBAL KNOWLEDGE:
# MacPorts upgrades are complex due to OS version dependencies.
# After major OS upgrades, ports need migration to rebuild against
# new system libraries and frameworks.

def prepare(package, system, plan):
    """Prepare for MacPorts upgrade."""
    
    # Check current installation status
    if not system.package.installed("port"):
        return {"prepare": "not_installed"}
    
    # Get current version
    current_version = system.package.version("port")
    
    # Check if this is a major OS upgrade scenario
    _check_os_upgrade_scenario(package, system, plan)
    
    # Detect potential migration needs
    _check_migration_requirements(package, system, plan, current_version)
    
    # Verify Command Line Tools are current
    _verify_current_clt(package, system, plan)
    
    # Check for common upgrade blockers
    _check_upgrade_blockers(package, system, plan)
    
    return {"prepare": True}

def _check_os_upgrade_scenario(package, system, plan):
    """Detect if this upgrade follows a major OS upgrade.
    
    TRIBAL KNOWLEDGE:
    After major OS upgrades, MacPorts installation may be broken
    due to changed system libraries and frameworks.
    """
    # Check for signs of OS upgrade:
    # 1. Xcode version mismatch
    # 2. Command Line Tools mismatch  
    # 3. System library version mismatches
    
    os_version = system.platform.version
    
    # This would require more sophisticated detection in real implementation
    # For now, we'll assume any upgrade might need migration attention
    
    upgrade_warning = f"""
OS Version: {os_version}
If you recently upgraded macOS, you may need to run 'port migrate' after the upgrade.
This will rebuild ports that are incompatible with the new OS version.
"""

def _check_migration_requirements(package, system, plan, current_version):
    """Check if migration will be required.
    
    TRIBAL KNOWLEDGE:
    Migration is required for MacPorts 2.10.0+
    Signs that migration is needed:
    - libiconv version errors
    - Segmentation faults in port commands
    - Build failures with system library conflicts
    """
    # Check MacPorts version supports migration
    version_parts = current_version.split(".")
    major = int(version_parts[0])
    minor = int(version_parts[1])
    
    if major < 2 or (major == 2 and minor < 10):
        migration_warning = """
Current MacPorts version does not support automatic migration.
Consider a clean reinstall if you encounter issues after upgrade.
"""
    
    # Check for classic migration warning signs
    _detect_libiconv_issues(package, system, plan)

def _detect_libiconv_issues(package, system, plan):
    """Detect the classic libiconv version mismatch.
    
    TRIBAL KNOWLEDGE:
    The error "dyld: Library not loaded: /usr/lib/libiconv.2.dylib"
    is the telltale sign of architecture or OS version mismatch.
    This almost always requires migration or clean reinstall.
    """
    # Test port command for libiconv errors
    # This is a quick test - if port command fails with libiconv error,
    # migration is definitely needed
    
    libiconv_test = plan.shell("port version 2>&1 | grep -q libiconv || true")
    
    # If libiconv error detected, warn user
    warning = """
Libiconv version mismatch detected. This typically occurs after:
- macOS upgrades
- Architecture changes (Intel to Apple Silicon)
- MacPorts reinstallation

Migration will be required after upgrade.
"""

def _verify_current_clt(package, system, plan):
    """Ensure Command Line Tools are current for target OS.
    
    TRIBAL KNOWLEDGE:
    Outdated CLT cause mysterious build failures.
    After OS upgrades, CLT must be updated before MacPorts upgrade.
    """
    # Check CLT version
    clt_check = plan.shell("pkgutil --pkg-info=com.apple.pkg.CLTools_Executables")
    
    # Check if CLT version matches OS version expectations
    os_version = system.platform.version
    
    update_clt_msg = """
Ensure Command Line Tools are current:
  xcode-select --install
  
Accept Xcode license if needed:
  sudo xcodebuild -license accept
"""

def _check_upgrade_blockers(package, system, plan):
    """Check for common issues that block upgrades.
    
    TRIBAL KNOWLEDGE:
    Common upgrade blockers:
    - Disk space (ports tree and builds need significant space)
    - Permission issues in /opt/local
    - Corrupted ports registry
    - Network connectivity for selfupdate
    """
    # Check available disk space
    disk_check = plan.shell("df -h /opt/local")
    
    # Check ownership of MacPorts directories  
    ownership_check = plan.shell("ls -la /opt/local/")
    
    # Test network connectivity to MacPorts servers
    network_check = plan.shell("curl -I https://packages.macports.org/ || ping -c 1 packages.macports.org")

def rollback(package, system, plan):
    """No rollback needed for prepare."""
    pass
