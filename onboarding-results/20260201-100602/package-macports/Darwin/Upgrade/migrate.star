# macports/Darwin/Upgrade/migrate.star - Migrate phase for MacPorts
#
# TRIBAL KNOWLEDGE:
# MacPorts migration is required after major OS upgrades or architecture changes.
# The 'port migrate' command attempts to rebuild all ports with the new base,
# but this can fail if ports are no longer available or have dependency conflicts.
# A full reinstall is sometimes the only option.

def migrate():
    """Migrate MacPorts installation after upgrade."""
    if _needs_migration():
        _perform_migration()
    else:
        _upgrade_outdated_ports()
    
    return {"migrate": True}

def _needs_migration():
    """Determine if migration is needed."""
    # Check for common migration indicators
    
    # 1. Check if any ports report as broken
    result = shell.exec("port -q installed broken", allowed_commands=["port"])
    if result.success and result.stdout.strip():
        print("Broken ports detected - migration needed")
        return True
    
    # 2. Check for architecture mismatches on Apple Silicon
    if platform.arch == "arm64":
        result = shell.exec(
            "port -q installed | grep 'x86_64'",
            allowed_commands=["port", "grep"]
        )
        if result.success and result.stdout.strip():
            print("Intel ports found on Apple Silicon - migration needed")
            return True
    
    # 3. Check if port registry is inconsistent
    result = shell.exec("sudo port -d selfupdate", allowed_commands=["port"])
    if not result.success:
        print("Port registry issues detected - migration may be needed")
        return True
    
    return False

def _perform_migration():
    """Perform MacPorts migration."""
    print("Starting MacPorts migration...")
    print("This may take a long time as ports are rebuilt from source")
    
    # First, try the built-in migration
    result = shell.exec(
        "sudo port migrate",
        allowed_commands=["port"]
    )
    
    if result.success:
        print("MacPorts migration completed successfully")
        return
    
    # If migration failed, offer manual migration
    print("Automated migration failed. Attempting manual migration...")
    _manual_migration()

def _manual_migration():
    """Perform manual migration when automated migration fails."""
    backup_file = "/tmp/macports_installed_ports.txt"
    
    # Check if we have a backup from prepare phase
    if not fs.exists(backup_file):
        print("Creating port list backup...")
        shell.exec(
            f"port -qv installed > {backup_file}",
            allowed_commands=["port"]
        )
    
    print("WARNING: Manual migration required")
    print("The following steps will be attempted:")
    print("1. Uninstall all ports")
    print("2. Clean port registry")
    print("3. Reinstall ports from backup list")
    
    # Uninstall all ports (keeping dependencies)
    print("Uninstalling all ports...")
    shell.exec(
        "sudo port -f uninstall installed",
        allowed_commands=["port"]
    )
    
    # Clean the registry
    print("Cleaning port registry...")
    shell.exec(
        "sudo port -f clean all",
        allowed_commands=["port"]
    )
    
    # Reinstall from backup
    if fs.exists(backup_file):
        print("Reinstalling ports from backup...")
        content = fs.read(backup_file)
        port_lines = [line.strip() for line in content.split('\n') if line.strip()]
        
        # Extract just the port names (first column)
        port_names = []
        for line in port_lines:
            parts = line.split()
            if parts:
                # Handle format: "port-name @version+variants"
                port_name = parts[0].split('@')[0]
                if port_name not in port_names:
                    port_names.append(port_name)
        
        if port_names:
            ports_to_install = ' '.join(port_names[:10])  # Install in batches
            print(f"Installing first batch of ports: {ports_to_install}")
            result = shell.exec(
                f"sudo port install {ports_to_install}",
                allowed_commands=["port"]
            )
            
            if result.success:
                print("First batch installed successfully")
                print(f"Remaining ports from backup file: {backup_file}")
                print("Run manually: sudo port install <remaining-ports>")
            else:
                print("Port installation failed - check backup file manually")

def _upgrade_outdated_ports():
    """Upgrade any outdated ports after migration."""
    print("Checking for outdated ports...")
    result = shell.exec("port outdated", allowed_commands=["port"])
    
    if result.success and result.stdout.strip():
        print("Upgrading outdated ports...")
        shell.exec(
            "sudo port upgrade outdated",
            allowed_commands=["port"]
        )
    else:
        print("All ports are up to date")

def rollback():
    """Rollback migration if possible."""
    backup_file = "/tmp/macports_installed_ports.txt"
    
    if fs.exists(backup_file):
        print(f"Port backup available at {backup_file}")
        print("Manual restoration may be possible using:")
        print("  sudo port install $(cat /tmp/macports_installed_ports.txt | awk '{print $1}')")
    else:
        print("No port backup available - rollback not possible")
