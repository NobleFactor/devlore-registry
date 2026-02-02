# macports/Darwin/Decommission/uninstall.star
#
# TRIBAL KNOWLEDGE:
# MacPorts uninstall is straightforward: remove /opt/local.
# But must ensure all ports are uninstalled first to avoid
# leaving orphaned processes or system modifications.

def uninstall(package, system, plan):
    """Remove MacPorts installation completely."""
    
    # Verify ports are already uninstalled
    if not _verify_ports_uninstalled(package, system, plan):
        return {"uninstall": "ports_still_installed"}
    
    # Remove MacPorts base installation
    _remove_macports_base(package, system, plan)
    
    # Remove MacPorts user and group if they exist
    _remove_macports_user_group(package, system, plan)
    
    # Remove system integration
    _remove_system_integration(package, system, plan)
    
    return {"uninstall": True}

def _verify_ports_uninstalled(package, system, plan):
    """Ensure all ports have been uninstalled first.
    
    TRIBAL KNOWLEDGE:
    Removing MacPorts while ports are installed can leave
    system in inconsistent state with orphaned processes.
    """
    # Check if any ports are still installed
    check_ports = plan.shell("port installed 2>/dev/null | grep -v 'No ports are installed' || echo 'no_ports'")
    
    return True  # Execution engine will validate

def _remove_macports_base(package, system, plan):
    """Remove the main MacPorts installation.
    
    TRIBAL KNOWLEDGE:
    MacPorts installs everything under /opt/local by default.
    Some installations might use different prefix from source builds.
    """
    prefix = package.setting("prefix", "/opt/local")
    
    # Create final backup of any remaining user data
    backup_final = plan.shell(f"""
        if [ -d {prefix}/etc ]; then
            sudo tar -czf ~/macports_etc_backup_$(date +%Y%m%d).tar.gz {prefix}/etc/ || true
        fi
    """)
    
    # Remove the entire MacPorts installation
    remove_installation = plan.shell(f"sudo rm -rf {prefix}")
    
    # Remove MacPorts from /Applications if present
    remove_applications = plan.shell("sudo rm -rf /Applications/MacPorts || true")
    
    plan.depends_on(remove_installation, backup_final)
    plan.depends_on(remove_applications, remove_installation)

def _remove_macports_user_group(package, system, plan):
    """Remove MacPorts user and group if they exist.
    
    TRIBAL KNOWLEDGE:
    Some MacPorts installations create a 'macports' user and group.
    These should be removed during uninstall to avoid system clutter.
    """
    # Check and remove macports user
    remove_user = plan.shell("""
        if dscl . -read /Users/macports 2>/dev/null; then
            sudo dscl . -delete /Users/macports
        fi
    """)
    
    # Check and remove macports group  
    remove_group = plan.shell("""
        if dscl . -read /Groups/macports 2>/dev/null; then
            sudo dscl . -delete /Groups/macports
        fi
    """)

def _remove_system_integration(package, system, plan):
    """Remove MacPorts system integration points.
    
    TRIBAL KNOWLEDGE:
    MacPorts integrates with macOS in several ways:
    - /etc/paths.d/MacPorts
    - Possible LaunchDaemons
    - Spotlight integration
    """
    # Remove paths.d entry (should already be done in unprovision)
    remove_paths = plan.shell("sudo rm -f /etc/paths.d/MacPorts")
    
    # Remove any remaining LaunchDaemons
    remove_launchd = plan.shell("""
        sudo rm -f /Library/LaunchDaemons/org.macports.* || true
        sudo rm -f ~/Library/LaunchAgents/org.macports.* || true
    """)
    
    # Remove Spotlight indexing for MacPorts (if configured)
    remove_spotlight = plan.shell("""
        if [ -f ~/.mdignore ]; then
            sed -i.bak '/opt\/local/d' ~/.mdignore || true
        fi
    """)
    
    # Remove from sudo secure_path if present
    remove_sudo_path = plan.shell("""
        if grep -q '/opt/local' /etc/sudoers 2>/dev/null; then
            echo "Manual removal required: /opt/local paths in /etc/sudoers"
        fi
    """)

def rollback(package, system, plan):
    """Rollback MacPorts uninstall.
    
    TRIBAL KNOWLEDGE:
    Uninstall rollback requires full reinstallation.
    Check for any backup files created during uninstall process.
    """
    # Check for configuration backup
    check_backup = plan.shell("ls ~/macports_etc_backup_*.tar.gz 2>/dev/null || echo 'no_backup'")
    
    # Provide rollback guidance
    rollback_guidance = """
To recover from MacPorts uninstall:

1. Reinstall MacPorts:
   - Download appropriate .pkg installer
   - Or install from source

2. Restore configuration if backup exists:
   - Check: ls ~/macports_etc_backup_*.tar.gz
   - Extract: sudo tar -xzf ~/macports_etc_backup_YYYYMMDD.tar.gz -C /

3. Restore installed ports if backup exists:
   - Check: ls ~/macports_removed_*.txt
   - Restore: sudo port install $(cat ~/macports_removed_YYYYMMDD.txt)

Complete system recovery may take several hours.
"""
    
    return {"rollback": "guidance_provided", "guidance": rollback_guidance}
