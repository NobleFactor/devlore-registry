# macports/Darwin/Deploy/verify.star
#
# TRIBAL KNOWLEDGE:
# Must run 'sudo port selfupdate' after installation to download the
# latest ports tree and ensure MacPorts is fully functional. This is
# critical for security updates and package availability.

def verify(package, system, plan):
    """Verify MacPorts installation and perform initial setup."""
    
    # Check that port command is available
    check_port = plan.shell("which port")
    
    # Verify version matches expected
    check_version = plan.shell(f"port version | grep -q 'Version: {package.version}'")
    
    # Run initial selfupdate to sync ports tree
    selfupdate = plan.shell("sudo port -v selfupdate")
    
    # Test basic functionality
    list_ports = plan.shell("port list | head -5")
    
    # Dependencies
    plan.depends_on(check_version, check_port)
    plan.depends_on(selfupdate, check_version)
    plan.depends_on(list_ports, selfupdate)
    
    return {"verify": True}

def rollback(package, system, plan):
    """No rollback needed for verify phase."""
    return {"rollback": True}

