# macports/Darwin/Deploy/verify.star - Verify phase for MacPorts

def verify():
    """Verify MacPorts installation is working correctly."""
    _verify_port_command()
    _verify_version()
    _verify_selfupdate()
    _verify_basic_functionality()
    return {"verify": True}

def _verify_port_command():
    """Verify port command is available and executable."""
    if not fs.which("port"):
        fail("port command not found in PATH")
    
    result = shell.exec("which port", allowed_commands=["which"])
    if not result.success:
        fail("port command not accessible")
    
    print(f"MacPorts found at: {result.stdout.strip()}")

def _verify_version():
    """Verify MacPorts version matches expected."""
    result = shell.exec("port version", allowed_commands=["port"])
    if not result.success:
        fail("Failed to get MacPorts version")
    
    version_output = result.stdout.strip()
    print(f"MacPorts version: {version_output}")
    
    # Check version format
    if "Version: 2.11.6" not in version_output:
        fail(f"Unexpected version output: {version_output}")

def _verify_selfupdate():
    """Verify selfupdate functionality works."""
    result = shell.exec(
        "sudo port -v selfupdate",
        allowed_commands=["port"]
    )
    
    if not result.success:
        # This might fail due to network issues, so warn rather than fail
        print("WARNING: selfupdate check failed. This might be a network issue.")
        print("Try running 'sudo port -v selfupdate' manually.")
    else:
        print("MacPorts selfupdate verified")

def _verify_basic_functionality():
    """Test basic MacPorts functionality."""
    # Test search functionality
    result = shell.exec("port search --name --exact git", allowed_commands=["port"])
    if not result.success:
        fail("MacPorts search functionality not working")
    
    # Test info functionality
    result = shell.exec("port info git", allowed_commands=["port"])
    if not result.success:
        fail("MacPorts info functionality not working")
    
    print("MacPorts basic functionality verified")

def rollback():
    """No rollback needed for verification."""
    pass
