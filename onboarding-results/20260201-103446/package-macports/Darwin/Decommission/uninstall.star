# macports/Darwin/Decommission/uninstall.star
#
# TRIBAL KNOWLEDGE:
# MacPorts doesn't provide an official uninstaller. Complete removal
# requires manually deleting directories, users, and groups created
# during installation. The /opt/local directory contains all installed
# software and should be completely removed.

def uninstall(package, system, plan):
    """Remove all MacPorts software and data."""
    
    # Uninstall all ports first to clean up properly
    uninstall_all_ports = plan.shell("sudo port -f uninstall installed 2>/dev/null || true")
    
    # Remove MacPorts directory structure
    remove_opt_local = plan.shell("sudo rm -rf /opt/local")
    
    # Remove Applications folder entry
    remove_applications = plan.shell("sudo rm -rf /Applications/MacPorts")
    
    # Remove receipts (for .pkg installations)
    remove_receipts = plan.shell("sudo pkgutil --forget org.macports.MacPorts 2>/dev/null || true")
    
    # Dependencies
    plan.depends_on(remove_opt_local, uninstall_all_ports)
    
    return {"uninstall": True}

def rollback(package, system, plan):
    """Cannot rollback uninstall - would require reinstallation."""
    return {"rollback": False, "error": "Cannot rollback uninstall operation"}

