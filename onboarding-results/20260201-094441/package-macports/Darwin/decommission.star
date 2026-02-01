# macports/Darwin/decommission.star - Decommission phase for MacPorts on macOS
#
# TRIBAL KNOWLEDGE:
# MacPorts decommissioning should be graceful:
# 1. Save list of installed ports for potential restoration
# 2. Uninstall all ports cleanly (not just rm -rf)
# 3. Stop any running services started by ports
# 4. Preserve user data where possible

def decommission():
    """Gracefully shutdown MacPorts services and prepare for removal."""
    _backup_port_list()
    _stop_port_services()
    _uninstall_all_ports()
    return {"decommission": True}

def _backup_port_list():
    """Save list of installed ports for potential restoration."""
    print("Backing up list of installed ports...")
    
    backup_file = "/tmp/macports_installed_ports_backup.txt"
    
    # Create detailed backup with variants
    shell.exec(
        f"port -qv installed > {backup_file}",
        allowed_commands=["port"],
        check=False,
    )
    
    # Also create simple list for easy reinstall
    simple_backup = "/tmp/macports_ports_simple.txt"
    shell.exec(
        f"port -q installed | awk '{{print $1}}' > {simple_backup}",
        allowed_commands=["port", "awk"],
        check=False,
    )
    
    if fs.exists(backup_file):
        print(f"Port list backed up to {backup_file}")
        print(f"Simple port list saved to {simple_backup}")
        print("To restore later: sudo port install $(cat /tmp/macports_ports_simple.txt)")
    else:
        print("Warning: Could not create port backup")

def _stop_port_services():
    """Stop services that may have been started by installed ports."""
    print("Stopping services started by MacPorts...")
    
    # TRIBAL KNOWLEDGE:
    # Many ports install LaunchDaemons/LaunchAgents that need to be stopped
    # before uninstalling. MacPorts doesn't always clean these up automatically.
    
    # Find LaunchDaemons installed by MacPorts
    macports_plists = []
    
    launchd_dirs = [
        "/Library/LaunchDaemons",
        "/Library/LaunchAgents",
        "/System/Library/LaunchDaemons",
        "/System/Library/LaunchAgents",
    ]
    
    for launchd_dir in launchd_dirs:
        if fs.exists(launchd_dir):
            result = shell.exec(
                f"find {launchd_dir} -name '*macports*' -o -name '*opt.local*'",
                allowed_commands=["find"],
                check=False,
            )
            
            if result.returncode == 0 and result.stdout.strip():
                for plist in result.stdout.strip().split("\n"):
                    if plist.strip():
                        macports_plists.append(plist.strip())
    
    # Stop and unload found services
    for plist in macports_plists:
        plist_name = plist.split("/")[-1].replace(".plist", "")
        print(f"Stopping service: {plist_name}")
        
        shell.exec(
            f"sudo launchctl unload {plist}",
            allowed_commands=["launchctl"],
            check=False,
        )
    
    # Also check for any running processes from /opt/local
    result = shell.exec(
        "ps aux | grep /opt/local | grep -v grep",
        allowed_commands=["ps", "grep"],
        check=False,
    )
    
    if result.returncode == 0 and result.stdout.strip():
        print("Warning: Some MacPorts processes may still be running:")
        print(result.stdout)
        print("Consider stopping them manually before proceeding.")

def _uninstall_all_ports():
    """Uninstall all MacPorts ports cleanly."""
    print("Uninstalling all MacPorts ports...")
    
    # Get list of installed ports
    result = shell.exec(
        "port installed",
        allowed_commands=["port"],
        check=False,
    )
    
    if result.returncode != 0:
        print("Could not list installed ports - MacPorts may already be broken")
        return
    
    # Count ports for progress indication
    port_lines = [l for l in result.stdout.split("\n") if l.strip() and not l.startswith("The following")]
    port_count = len(port_lines)
    
    if port_count == 0:
        print("No ports are installed")
        return
    
    print(f"Uninstalling {port_count} ports...")
    
    # TRIBAL KNOWLEDGE:
    # Use -f (force) flag to handle dependency issues during mass uninstall
    # Uninstall in reverse dependency order when possible
    shell.exec(
        "sudo port -f uninstall installed",
        allowed_commands=["port"],
        check=False,
    )
    
    # Verify all ports were removed
    result = shell.exec(
        "port installed",
        allowed_commands=["port"],
        check=False,
    )
    
    if result.returncode == 0:
        remaining_ports = [l for l in result.stdout.split("\n") if l.strip() and not l.startswith("The following")]
        if remaining_ports:
            print(f"Warning: {len(remaining_ports)} ports could not be uninstalled:")
            for port in remaining_ports[:5]:  # Show first 5
                print(f"  {port.strip()}")
            if len(remaining_ports) > 5:
                print(f"  ... and {len(remaining_ports) - 5} more")
        else:
            print("✓ All ports uninstalled successfully")

def rollback():
    """Restore MacPorts to pre-decommission state."""
    print("Restoring MacPorts from backup...")
    
    backup_file = "/tmp/macports_ports_simple.txt"
    
    if not fs.exists(backup_file):
        print("No backup file found - cannot restore automatically")
        return
    
    print("Reinstalling ports from backup...")
    shell.exec(
        f"sudo port install $(cat {backup_file})",
        allowed_commands=["port", "cat"],
        check=False,
    )
    
    print("Port restoration initiated - this may take a while")
