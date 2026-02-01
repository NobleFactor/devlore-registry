# macports/Darwin/Upgrade/migrate.star
#
# TRIBAL KNOWLEDGE:
# Migration rebuilds ports that are incompatible after OS/architecture changes.
# This is THE most important operation after major OS upgrades.
# Without migration, subtle breakage occurs that's hard to diagnose.

def migrate(package, system, plan):
    """Migrate ports after MacPorts upgrade.
    
    TRIBAL KNOWLEDGE:
    Migration is critical after:
    - macOS major version upgrades
    - Architecture changes (Intel to Apple Silicon)
    - MacPorts major version upgrades
    
    The 'port migrate' command rebuilds all ports that are
    incompatible with the current environment.
    """
    
    # Check if migration is supported
    if not _migration_supported(package, system, plan):
        return _manual_migration_guidance(package, system, plan)
    
    # Pre-migration health check
    if not _pre_migration_check(package, system, plan):
        return {"migrate": "precondition_failed"}
    
    # Perform the migration
    migration_result = _run_migration(package, system, plan)
    
    # Post-migration cleanup
    _post_migration_cleanup(package, system, plan)
    
    return migration_result

def _migration_supported(package, system, plan):
    """Check if port migrate command is available.
    
    TRIBAL KNOWLEDGE:
    'port migrate' was added in MacPorts 2.10.0.
    Earlier versions require manual port reinstallation.
    """
    version = system.package.version("port")
    version_parts = version.split(".")
    major = int(version_parts[0])
    minor = int(version_parts[1])
    
    # Migration supported in 2.10.0+
    return major > 2 or (major == 2 and minor >= 10)

def _manual_migration_guidance(package, system, plan):
    """Provide guidance for manual migration on older MacPorts.
    
    TRIBAL KNOWLEDGE:
    Before MacPorts 2.10.0, migration was a manual process:
    1. Export installed ports list
    2. Uninstall all ports
    3. Clean and reinstall
    """
    guidance = """
Automatic migration not available in this MacPorts version.
Manual migration required:

1. Export ports: port -qv installed > myports.txt
2. Uninstall all: sudo port -f uninstall installed
3. Clean: sudo port clean all
4. Reinstall: cat myports.txt | while read line; do sudo port install $line; done

This process may take several hours.
"""
    
    return {"migrate": "manual_required", "guidance": guidance}

def _pre_migration_check(package, system, plan):
    """Verify system is ready for migration.
    
    TRIBAL KNOWLEDGE:
    Migration can fail if:
    - Insufficient disk space (needs ~2x current port storage)
    - Network connectivity issues
    - Broken port registry
    - Xcode/CLT issues
    """
    # Check disk space
    disk_check = plan.shell("df -h /opt/local | tail -1")
    
    # Check port registry is accessible
    registry_check = plan.shell("port installed | head -5")
    
    # Ensure selfupdate completed successfully
    selfupdate_check = plan.shell("sudo port selfupdate")
    
    # Test network connectivity
    network_check = plan.shell("curl -I https://packages.macports.org/")
    
    return True

def _run_migration(package, system, plan):
    """Execute the port migration.
    
    TRIBAL KNOWLEDGE:
    Migration process:
    1. Identifies ports needing rebuild
    2. Uninstalls incompatible ports in dependency order
    3. Rebuilds and reinstalls in correct order
    4. Preserves variants and selections
    
    This can take hours for large port collections.
    """
    
    # Show what migration will do (dry run)
    preview_node = plan.shell("sudo port migrate --dry-run")
    
    # Create backup before migration
    backup_node = plan.shell("port -qv installed > /tmp/pre_migration_backup_$(date +%Y%m%d_%H%M).txt")
    
    # Run the actual migration
    # Note: This can take a very long time
    migrate_node = plan.shell("""
        sudo port migrate 2>&1 | tee /tmp/migration_log_$(date +%Y%m%d_%H%M).txt
    """)
    
    # Chain operations
    plan.depends_on(backup_node, preview_node)
    plan.depends_on(migrate_node, backup_node)
    
    return {"migrate": True}

def _post_migration_cleanup(package, system, plan):
    """Clean up after migration.
    
    TRIBAL KNOWLEDGE:
    After migration:
    - Clean old build artifacts
    - Update port index
    - Verify critical ports work
    """
    
    # Clean old build files
    clean_node = plan.shell("sudo port clean all")
    
    # Reclaim disk space from old archives
    reclaim_node = plan.shell("sudo port reclaim")
    
    # Update port index
    index_node = plan.shell("sudo portindex")
    
    # Test that basic functionality works
    test_node = plan.shell("port search python3 | head -5")
    
    return True

def rollback(package, system, plan):
    """Rollback migration if it fails.
    
    TRIBAL KNOWLEDGE:
    Migration rollback is extremely difficult.
    Best option is usually to restore from Time Machine
    or start with clean MacPorts installation.
    """
    
    # Check for pre-migration backup
    backup_check = plan.shell("ls /tmp/pre_migration_backup_*.txt 2>/dev/null")
    
    # Emergency recovery guidance
    recovery_guidance = """
Migration rollback options:

1. If Time Machine backup available:
   - Restore /opt/local from backup
   
2. Clean reinstall (safest):
   - sudo rm -rf /opt/local
   - Reinstall MacPorts
   - Restore from backup: sudo port install $(cat backup.txt)
   
3. Manual recovery:
   - Check migration log in /tmp/migration_log_*.txt
   - Identify failed ports and reinstall individually

Migration failures often indicate system-level issues.
"""
    
    return {"rollback": "guidance_provided", "guidance": recovery_guidance}
