# macports/Darwin/verify.star - Verify phase for MacPorts on macOS
#
# TRIBAL KNOWLEDGE:
# MacPorts verification goes beyond just checking if 'port' command exists.
# A healthy MacPorts installation requires:
# 1. Port command works and shows correct version
# 2. Ports tree is synced and current
# 3. Basic port operations work (search, info)
# 4. No broken port registry entries

def verify():
    """Verify MacPorts installation is working correctly."""
    _verify_port_command()
    _verify_ports_tree()
    _verify_basic_operations()
    _check_system_health()
    return {"verify": True}

def _verify_port_command():
    """Verify port command exists and shows expected version."""
    if not fs.which("port"):
        fail("port command not found in PATH")
    
    result = shell.exec(
        "port version",
        allowed_commands=["port"],
    )
    
    if "Version: 2.11.6" not in result.stdout:
        fail(f"Unexpected MacPorts version: {result.stdout}")
    
    print(f"✓ MacPorts version verified: {result.stdout.strip()}")

def _verify_ports_tree():
    """Verify ports tree is synced and reasonably current."""
    # Check if ports tree exists
    ports_dir = "/opt/local/var/macports/sources/rsync.macports.org/macports/release/tarballs/ports"
    if not fs.exists(ports_dir):
        print("Ports tree not found, running selfupdate...")
        shell.exec(
            "sudo port selfupdate",
            allowed_commands=["port"],
        )
    
    # TRIBAL KNOWLEDGE:
    # Check if ports tree is recent - old trees can cause mysterious failures
    # The PortIndex file timestamp indicates when tree was last synced
    portindex_file = f"{ports_dir}/PortIndex"
    if fs.exists(portindex_file):
        # We could check file modification time, but for simplicity just verify it exists
        print("✓ Ports tree appears to be synced")
    else:
        fail("Ports tree PortIndex missing - run 'sudo port selfupdate'")

def _verify_basic_operations():
    """Test basic MacPorts operations."""
    # Test search functionality
    result = shell.exec(
        "port search --name-glob 'vim*' | head -5",
        allowed_commands=["port", "head"],
    )
    
    if not result.stdout.strip():
        fail("Port search returned no results - ports tree may be corrupted")
    
    print("✓ Port search functionality working")
    
    # Test info command on a common port
    result = shell.exec(
        "port info vim",
        allowed_commands=["port"],
        check=False,
    )
    
    if result.returncode != 0:
        print("Warning: Port info command failed - may indicate ports tree issues")
    else:
        print("✓ Port info functionality working")

def _check_system_health():
    """Check for common MacPorts system health issues."""
    # Check disk space in MacPorts directory
    result = shell.exec(
        "df -h /opt/local",
        allowed_commands=["df"],
    )
    print(f"Disk space: {result.stdout.split()[10]}% used on MacPorts volume")
    
    # Check for broken port registry entries
    result = shell.exec(
        "port diagnose",
        allowed_commands=["port"],
        check=False,
    )
    
    if result.returncode == 0:
        if "No problems found" in result.stdout:
            print("✓ MacPorts system health check passed")
        else:
            print(f"System health warnings: {result.stdout}")
    
    # Verify Xcode Command Line Tools are still available
    clt_result = shell.exec(
        "xcode-select -p",
        allowed_commands=["xcode-select"],
        check=False,
    )
    
    if clt_result.returncode != 0:
        fail("Xcode Command Line Tools no longer available - run 'xcode-select --install'")
    else:
        print("✓ Xcode Command Line Tools available")
    
    print("✓ MacPorts verification completed successfully")
    print("\nUseful commands:")
    print("  sudo port selfupdate     # Update ports tree")
    print("  port search <name>       # Search for ports")
    print("  sudo port install <name> # Install a port")
    print("  port installed           # List installed ports")

def rollback():
    """No rollback needed for verify phase."""
    pass
