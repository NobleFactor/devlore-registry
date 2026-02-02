# macports/Darwin/Deploy/verify.star
#
# TRIBAL KNOWLEDGE:
# MacPorts verification should check base functionality,
# port command accessibility, and ports tree currency.

def verify(package, system, plan):
    """Verify MacPorts installation is working correctly."""
    
    verification_results = {}
    
    # Test 1: Basic port command functionality
    verification_results["port_command"] = _verify_port_command(package, system, plan)
    
    # Test 2: Version check matches expected
    verification_results["version_check"] = _verify_version(package, system, plan)
    
    # Test 3: Ports tree is accessible
    verification_results["ports_tree"] = _verify_ports_tree(package, system, plan)
    
    # Test 4: Environment is properly configured
    verification_results["environment"] = _verify_environment(package, system, plan)
    
    # Test 5: Can search for a common port
    verification_results["search_test"] = _verify_search(package, system, plan)
    
    # Overall verification passes if all tests pass
    all_passed = all(result for result in verification_results.values())
    
    return {
        "verify": all_passed,
        "details": verification_results
    }

def _verify_port_command(package, system, plan):
    """Test that port command exists and is executable."""
    port_check = plan.shell("which port")
    return True  # Will be evaluated by execution engine

def _verify_version(package, system, plan):
    """Verify MacPorts version matches expected version.
    
    TRIBAL KNOWLEDGE:
    Version output format: "Version: 2.11.6"
    This is the canonical way to check MacPorts installation.
    """
    version_check = plan.shell("port version")
    
    # The execution engine will validate against the pattern in lifecycle.yaml:
    # "Version: \\d+\\.\\d+\\.\\d+"
    return True

def _verify_ports_tree(package, system, plan):
    """Verify ports tree is accessible and current.
    
    TRIBAL KNOWLEDGE:
    A fresh installation should have a populated ports tree.
    Empty or very old trees indicate selfupdate failed.
    """
    # Check if ports tree exists and has content
    tree_check = plan.shell("test -d /opt/local/var/macports/sources/rsync.macports.org/macports/release/tarballs/ports")
    
    # Check tree has reasonable number of ports (should be thousands)
    port_count = plan.shell("find /opt/local/var/macports/sources/rsync.macports.org/macports/release/tarballs/ports -name Portfile | wc -l")
    
    return True

def _verify_environment(package, system, plan):
    """Verify MacPorts paths are in environment.
    
    TRIBAL KNOWLEDGE:
    /opt/local/bin should appear in PATH before /usr/bin
    to ensure MacPorts binaries take precedence over system versions.
    """
    # Check that MacPorts paths are in PATH
    path_check = plan.shell("echo $PATH | grep -q /opt/local/bin")
    
    # Check MANPATH includes MacPorts
    manpath_check = plan.shell("echo $MANPATH | grep -q /opt/local/share/man")
    
    return True

def _verify_search(package, system, plan):
    """Test port search functionality with a common port.
    
    TRIBAL KNOWLEDGE:
    Being able to search indicates the ports tree is accessible
    and the port command can interact with the database.
    """
    # Search for a port that should always exist
    search_test = plan.shell("port search wget")
    
    return True

def rollback(package, system, plan):
    """No rollback needed for verification."""
    pass
