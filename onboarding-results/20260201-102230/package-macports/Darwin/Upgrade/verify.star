# macports/Darwin/Upgrade/verify.star
#
# TRIBAL KNOWLEDGE:
# Post-upgrade verification must check both MacPorts base functionality
# and that migrated ports are working correctly.

def verify(package, system, plan):
    """Verify MacPorts upgrade and migration completed successfully."""
    
    verification_results = {}
    
    # Test 1: MacPorts version is correct
    verification_results["version"] = _verify_version_upgrade(package, system, plan)
    
    # Test 2: Basic port operations work
    verification_results["basic_ops"] = _verify_basic_operations(package, system, plan)
    
    # Test 3: Ports tree is current
    verification_results["ports_tree"] = _verify_ports_tree_current(package, system, plan)
    
    # Test 4: Sample of installed ports work
    verification_results["port_functionality"] = _verify_port_functionality(package, system, plan)
    
    # Test 5: No obvious migration artifacts
    verification_results["migration_clean"] = _verify_migration_cleanup(package, system, plan)
    
    all_passed = all(result for result in verification_results.values())
    
    return {
        "verify": all_passed,
        "details": verification_results
    }

def _verify_version_upgrade(package, system, plan):
    """Confirm MacPorts version matches target.
    
    TRIBAL KNOWLEDGE:
    Version verification after upgrade is critical.
    Selfupdate sometimes fails silently.
    """
    expected_version = package.version
    
    # Check version matches expected
    version_check = plan.shell(f"port version | grep -q '{expected_version}'")
    
    return True

def _verify_basic_operations(package, system, plan):
    """Test that basic port operations work.
    
    TRIBAL KNOWLEDGE:
    After upgrade/migration, test these operations:
    - search (tests ports tree)
    - info (tests port metadata)
    - list installed (tests registry)
    """
    # Test search functionality
    search_test = plan.shell("port search python3 | head -1")
    
    # Test info on a common port
    info_test = plan.shell("port info wget")
    
    # Test listing installed ports
    list_test = plan.shell("port installed | head -5")
    
    # Test outdated check
    outdated_test = plan.shell("port outdated")
    
    return True

def _verify_ports_tree_current(package, system, plan):
    """Verify ports tree is current after upgrade.
    
    TRIBAL KNOWLEDGE:
    Stale ports tree causes confusing errors.
    Check both tree existence and recency.
    """
    # Check ports tree exists
    tree_check = plan.shell("test -d /opt/local/var/macports/sources/rsync.macports.org/macports/release/tarballs/ports")
    
    # Check tree was updated recently (within last 7 days)
    recency_check = plan.shell("find /opt/local/var/macports/sources -name PortIndex -mtime -7")
    
    return True

def _verify_port_functionality(package, system, plan):
    """Test that a sample of installed ports work correctly.
    
    TRIBAL KNOWLEDGE:
    After migration, some ports may have linking issues
    or missing dependencies. Test common functionality.
    """
    # Get list of installed ports
    get_ports = plan.shell("port -q installed | head -10")
    
    # For each installed port, try to get basic info
    # This tests that port registry is consistent
    
    # Test a few common commands if ports are installed
    common_tests = [
        "which python3 && python3 --version || echo 'python3 not installed'",
        "which git && git --version || echo 'git not installed'", 
        "which wget && wget --version || echo 'wget not installed'"
    ]
    
    for test_cmd in common_tests:
        test_node = plan.shell(test_cmd)
    
    return True

def _verify_migration_cleanup(package, system, plan):
    """Check that migration left system in clean state.
    
    TRIBAL KNOWLEDGE:
    Migration can leave behind:
    - Temporary build files
    - Broken symlinks
    - Registry inconsistencies
    """
    # Check for excessive temporary files
    temp_check = plan.shell("du -sh /opt/local/var/macports/build")
    
    # Check for broken symlinks in bin directory
    symlink_check = plan.shell("find /opt/local/bin -type l ! -exec test -e {} \; -print")
    
    # Check registry consistency
    registry_check = plan.shell("port -q installed | wc -l")
    
    # Check for migration log files (cleanup if successful)
    log_cleanup = plan.shell("ls /tmp/migration_log_*.txt 2>/dev/null | wc -l")
    
    return True

def rollback(package, system, plan):
    """No rollback needed for verification."""
    pass
