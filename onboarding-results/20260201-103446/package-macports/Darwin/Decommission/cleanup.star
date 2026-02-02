# macports/Darwin/Decommission/cleanup.star

def cleanup(package, system, plan):
    """Final cleanup of MacPorts users, groups, and remaining files."""
    
    # Remove macports user if it exists
    remove_user = plan.shell("sudo dscl . -delete /Users/macports 2>/dev/null || true")
    
    # Remove macports group if it exists  
    remove_group = plan.shell("sudo dscl . -delete /Groups/macports 2>/dev/null || true")
    
    # Remove any remaining configuration in /etc
    remove_etc_config = plan.shell("sudo rm -rf /etc/macports 2>/dev/null || true")
    
    # Remove startup items if any
    remove_startup_items = plan.shell("sudo rm -rf /Library/StartupItems/DarwinPortsStartup 2>/dev/null || true")
    
    # Remove any remaining files in /usr/local that MacPorts might have created
    remove_usr_local_links = plan.shell("sudo find /usr/local -lname '/opt/local/*' -delete 2>/dev/null || true")
    
    return {"cleanup": True}

def rollback(package, system, plan):
    """No rollback needed for cleanup phase."""
    return {"rollback": True}

