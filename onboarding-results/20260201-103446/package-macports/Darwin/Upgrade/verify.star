# macports/Darwin/Upgrade/verify.star

def verify(package, system, plan):
    """Verify MacPorts upgrade completed successfully."""
    
    # Check that port command works
    check_port = plan.shell("which port")
    
    # Verify new version
    check_version = plan.shell(f"port version | grep -q 'Version: {package.version}'")
    
    # Test that ports tree is current
    check_outdated = plan.shell("port outdated")
    
    # Test basic port operations
    test_search = plan.shell("port search wget | head -1")
    
    # Dependencies
    plan.depends_on(check_version, check_port)
    plan.depends_on(check_outdated, check_version)
    plan.depends_on(test_search, check_outdated)
    
    return {"verify": True}

def rollback(package, system, plan):
    """No rollback needed for verify phase."""
    return {"rollback": True}

