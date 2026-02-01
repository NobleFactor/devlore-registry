# macports/Darwin/Upgrade/verify.star - Verify phase for MacPorts upgrade

def verify():
    """Verify MacPorts upgrade was successful."""
    _verify_version_upgrade()
    _verify_port_functionality()
    _verify_no_broken_ports()
    return {"verify": True}

def _verify_version_upgrade():
    """Verify MacPorts is now at expected version."""
    result = shell.exec("port version", allowed_commands=["port"])
    if not result.success:
        fail("MacPorts not responding after upgrade")
    
    version_output = result.stdout.strip()
    print(f"MacPorts version after upgrade: {version_output}")
    
    if "Version: 2.11.6" not in version_output:
        fail(f"Upgrade failed - unexpected version: {version_output}")

def _verify_port_functionality():
    """Test basic port functionality after upgrade."""
    # Test selfupdate
    result = shell.exec("sudo port -v selfupdate", allowed_commands=["port"])
    if not result.success:
        fail("MacPorts selfupdate not working after upgrade")
    
    # Test search
    result = shell.exec("port search --name --exact git", allowed_commands=["port"])
    if not result.success:
        fail("MacPorts search not working after upgrade")
    
    print("MacPorts functionality verified after upgrade")

def _verify_no_broken_ports():
    """Check for broken ports after upgrade."""
    result = shell.exec("port -q installed broken", allowed_commands=["port"])
    if result.success and result.stdout.strip():
        broken_ports = result.stdout.strip()
        print(f"WARNING: Broken ports detected after upgrade: {broken_ports}")
        print("Consider running: sudo port upgrade --force <broken-port-names>")
    else:
        print("No broken ports detected")

def rollback():
    """No rollback needed for verification."""
    pass
