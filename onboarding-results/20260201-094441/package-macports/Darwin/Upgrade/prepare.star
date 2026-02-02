# macports/Darwin/Upgrade/prepare.star - Prepare phase for MacPorts upgrade

def prepare():
    """Prepare for MacPorts upgrade."""
    _check_current_installation()
    _backup_portfile_list()
    _check_os_compatibility()
    return {"prepare": True}

def _check_current_installation():
    """Verify MacPorts is currently installed."""
    if not fs.exists("/opt/local/bin/port"):
        fail("MacPorts not found. Cannot upgrade non-existent installation.")
    
    result = shell.exec("port version", allowed_commands=["port"])
    if not result.success:
        fail("Current MacPorts installation is not functional")
    
    print(f"Current MacPorts: {result.stdout.strip()}")

def _backup_portfile_list():
    """Create backup of currently installed ports."""
    backup_file = "/tmp/macports_installed_ports.txt"
    
    result = shell.exec(
        f"port -qv installed > {backup_file}",
        allowed_commands=["port"]
    )
    
    if result.success:
        print(f"Backed up port list to {backup_file}")
    else:
        print("WARNING: Could not backup port list")

def _check_os_compatibility():
    """Check if current OS version requires migration."""
    # Major OS upgrades typically require migration
    macos_version = platform.version
    major_version = int(macos_version.split('.')[0])
    
    if major_version >= 11:  # macOS 11+ uses different versioning
        print("macOS 11+ detected - may require migration after upgrade")
    
    # Check for architecture changes (Intel to Apple Silicon)
    if platform.arch == "arm64":
        print("Apple Silicon detected - ensure ports are compatible")

def rollback():
    """Clean up preparation artifacts."""
    backup_file = "/tmp/macports_installed_ports.txt"
    if fs.exists(backup_file):
        fs.remove(backup_file)
