# macports/Darwin/verify.star - Verify phase for MacPorts on macOS

def verify():
    """Verify MacPorts installation and functionality."""
    _verify_installation()
    _verify_ports_tree()
    _verify_basic_functionality()
    return {"verify": True}

def _verify_installation():
    """Verify MacPorts base is installed and functional."""
    # Check port command exists and is executable
    if not fs.exists("/opt/local/bin/port"):
        fail("MacPorts port command not found")
    
    # Verify version
    result = shell.exec(
        "/opt/local/bin/port version",
        allowed_commands=["port"],
    )
    if result.exit_code != 0:
        fail("Port command failed to execute")
    
    if "Version: 2." not in result.stdout:
        fail(f"Unexpected version output: {result.stdout}")
    
    print(f"MacPorts version: {result.stdout.strip()}")

def _verify_ports_tree():
    """Verify ports tree is available."""
    # Check ports tree directory exists
    if not fs.exists("/opt/local/var/macports/sources/rsync.macports.org/macports/release/tarballs/ports"):
        # Try to sync if missing
        result = shell.exec(
            "sudo /opt/local/bin/port -v selfupdate",
            allowed_commands=["port"],
        )
        if result.exit_code != 0:
            fail("Failed to sync ports tree")
    
    # Test port search functionality
    result = shell.exec(
        "/opt/local/bin/port search --name --glob 'python*' | head -5",
        allowed_commands=["port", "head"],
    )
    if result.exit_code != 0:
        fail("Port search functionality not working")

def _verify_basic_functionality():
    """Test basic MacPorts operations."""
    # Test port info on a common port
    result = shell.exec(
        "/opt/local/bin/port info python311",
        allowed_commands=["port"],
    )
    if result.exit_code != 0:
        fail("Port info command failed")
    
    # Verify we can list installed ports (should work even if empty)
    result = shell.exec(
        "/opt/local/bin/port installed",
        allowed_commands=["port"],
    )
    if result.exit_code != 0:
        fail("Port installed command failed")
    
    print("MacPorts basic functionality verified")

def rollback():
    """No rollback needed for verification."""
    pass

