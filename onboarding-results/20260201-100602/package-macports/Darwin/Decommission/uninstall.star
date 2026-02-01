# macports/Darwin/Decommission/uninstall.star - Uninstall phase for MacPorts
#
# TRIBAL KNOWLEDGE:
# MacPorts doesn't provide an official uninstaller, but there are established
# procedures for complete removal. All ports must be uninstalled first,
# then the base system can be removed.

def uninstall():
    """Uninstall MacPorts and all ports."""
    _uninstall_all_ports()
    _remove_macports_base()
    return {"uninstall": True}

def _uninstall_all_ports():
    """Remove all installed MacPorts packages."""
    if not fs.exists("/opt/local/bin/port"):
        print("MacPorts not found - nothing to uninstall")
        return
    
    print("Uninstalling all MacPorts packages...")
    
    # First, try to uninstall all ports gracefully
    result = shell.exec(
        "sudo port -f uninstall installed",
        allowed_commands=["port"]
    )
    
    if not result.success:
        print("Graceful port uninstall failed, forcing removal...")
        # Force removal if graceful fails
        shell.exec(
            "sudo port -f uninstall --follow-dependents installed",
            allowed_commands=["port"]
        )
    
    # Clean any remaining files
    shell.exec(
        "sudo port -f clean all",
        allowed_commands=["port"]
    )
    
    print("All ports uninstalled")

def _remove_macports_base():
    """Remove MacPorts base installation."""
    print("Removing MacPorts base system...")
    
    # Check for official uninstall script
    uninstall_script = "/opt/local/etc/macports/uninstall.sh"
    if fs.exists(uninstall_script):
        print("Using official uninstall script...")
        shell.exec(
            f"sudo {uninstall_script}",
            allowed_commands=["uninstall.sh"]
        )
    else:
        print("Manual removal of MacPorts directories...")
        _manual_removal()

def _manual_removal():
    """Manually remove MacPorts directories and files."""
    # Main MacPorts directories
    directories_to_remove = [
        "/opt/local",
        "/Applications/MacPorts",
        "/var/macports",
        "/etc/macports",
        "/Library/LaunchDaemons/org.macports.*",
        "/Library/LaunchAgents/org.macports.*"
    ]
    
    for directory in directories_to_remove:
        if "*" in directory:
            # Handle wildcard patterns
            shell.exec(f"sudo rm -rf {directory}", allowed_commands=["rm"])
        else:
            if fs.exists(directory):
                shell.exec(f"sudo rm -rf {directory}", allowed_commands=["rm"])
                print(f"Removed {directory}")
    
    # Remove user-specific files
    user_home = env.expand("~")
    user_files = [
        f"{user_home}/.macports",
        f"{user_home}/Library/Preferences/org.macports.*"
    ]
    
    for user_file in user_files:
        if "*" in user_file:
            shell.exec(f"rm -rf {user_file}", allowed_commands=["rm"])
        else:
            if fs.exists(user_file):
                fs.remove(user_file)
                print(f"Removed {user_file}")
    
    print("MacPorts manual removal completed")

def rollback():
    """Rollback uninstallation is not practical."""
    print("WARNING: MacPorts uninstallation rollback is not supported")
    print("You would need to reinstall MacPorts completely")
    print("Consider using Deploy operation to reinstall if needed")
