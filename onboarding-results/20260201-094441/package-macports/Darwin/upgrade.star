# macports/Darwin/upgrade.star - Upgrade phase for MacPorts on macOS
#
# TRIBAL KNOWLEDGE:
# MacPorts upgrades are complex because they depend on the type of change:
# 1. Minor version upgrade: Simple selfupdate
# 2. Major macOS upgrade: Migration required to rebuild ports for new OS
# 3. Architecture change (Intel->Apple Silicon): Full migration needed
#
# Migration preserves your installed ports but rebuilds them.
# Without migration, ports built for old OS/architecture will break.

def upgrade():
    """Upgrade MacPorts installation."""
    if _needs_migration():
        _perform_migration()
    else:
        _perform_selfupdate()
    return {"upgrade": True}

def _needs_migration():
    """Determine if migration is needed vs simple selfupdate."""
    if config.get("features.migration-mode", False):
        return True
    
    # Check if we're on a different macOS version than what MacPorts was built for
    # This is a heuristic check - real detection is more complex
    current_major = platform.version.split(".")[0]
    
    # Check macports.conf for any version-specific settings that might indicate
    # this installation is from a different OS version
    config_file = "/opt/local/etc/macports/macports.conf"
    if fs.exists(config_file):
        config_content = fs.read(config_file)
        
        # Look for architecture settings that might be wrong for current system
        if platform.arch == "arm64" and "x86_64" in config_content and "arm64" not in config_content:
            print("Architecture mismatch detected - migration recommended")
            return True
    
    return False

def _perform_migration():
    """Perform MacPorts migration for major OS changes."""
    print("Performing MacPorts migration...")
    
    # TRIBAL KNOWLEDGE:
    # Migration requires MacPorts 2.10.0+. Older versions must be fully reinstalled.
    version_result = shell.exec(
        "port version",
        allowed_commands=["port"],
    )
    
    if "Version:" not in version_result.stdout:
        fail("Could not determine MacPorts version")
    
    version_line = version_result.stdout.strip()
    print(f"Current MacPorts: {version_line}")
    
    # Check if migration is supported
    migration_supported = _check_migration_support()
    
    if not migration_supported:
        print("Migration not supported by this MacPorts version.")
        print("Performing clean reinstall instead...")
        _perform_clean_reinstall()
        return
    
    # Step 1: Update macports.conf if needed
    _update_macports_config()
    
    # Step 2: Update MacPorts base system first
    print("Updating MacPorts base system...")
    shell.exec(
        "sudo port selfupdate",
        allowed_commands=["port"],
    )
    
    # Step 3: Run migration
    print("Running port migration - this may take a while...")
    shell.exec(
        "sudo port migrate",
        allowed_commands=["port"],
    )
    
    print("Migration completed successfully!")

def _perform_selfupdate():
    """Perform regular MacPorts selfupdate."""
    print("Updating MacPorts...")
    
    shell.exec(
        "sudo port -v selfupdate",
        allowed_commands=["port"],
    )
    
    print("MacPorts selfupdate completed")

def _check_migration_support():
    """Check if current MacPorts version supports migration."""
    # This would need version parsing logic
    # For now, assume modern versions support it
    return True

def _perform_clean_reinstall():
    """Perform clean reinstall when migration isn't supported."""
    print("WARNING: Clean reinstall will remove all installed ports!")
    print("Consider backing up your port list first:")
    print("  port -qv installed > myports.txt")
    
    # Export current port list
    shell.exec(
        "port -qv installed > /tmp/macports_backup.txt",
        allowed_commands=["port"],
        check=False,
    )
    
    # Uninstall all ports
    shell.exec(
        "sudo port -f uninstall installed",
        allowed_commands=["port"],
    )
    
    # Remove and reinstall MacPorts base
    shell.exec(
        "sudo rm -rf /opt/local",
        allowed_commands=["rm"],
    )
    
    # Reinstall would happen in install phase
    print("MacPorts base removed. Reinstallation needed.")
    print("Your port list was saved to /tmp/macports_backup.txt")

def _update_macports_config():
    """Update macports.conf for new OS version if needed."""
    config_file = "/opt/local/etc/macports/macports.conf"
    
    if not fs.exists(config_file):
        return
    
    config_content = fs.read(config_file)
    modified = False
    
    # TRIBAL KNOWLEDGE:
    # Apple Silicon Macs may need universal_archs updated
    if platform.arch == "arm64":
        if "universal_archs" not in config_content or "arm64" not in config_content:
            config_content += "\n# Updated for Apple Silicon\nuniversal_archs arm64 x86_64\n"
            modified = True
    
    if modified:
        # Backup original
        shell.exec(
            f"sudo cp {config_file} {config_file}.backup",
            allowed_commands=["cp"],
        )
        
        # Write updated config
        fs.write(config_file, config_content)
        print("Updated macports.conf for current system")

def rollback():
    """Rollback upgrade attempt."""
    # Restore config backup if it exists
    config_backup = "/opt/local/etc/macports/macports.conf.backup"
    if fs.exists(config_backup):
        shell.exec(
            f"sudo mv {config_backup} /opt/local/etc/macports/macports.conf",
            allowed_commands=["mv"],
        )
        print("Restored original macports.conf")
    
    # For migration failures, there's not much we can do automatically
    # User may need to restore from backup or reinstall
    print("Manual intervention may be required to restore MacPorts")
    print("Consider reinstalling MacPorts if migration failed")
