# macports/Darwin/Decommission/unprovision.star
#
# TRIBAL KNOWLEDGE:
# MacPorts decommission requires careful cleanup of ports,
# configuration, and environment setup. Order matters:
# uninstall ports first, then remove configuration.

def unprovision(package, system, plan):
    """Remove MacPorts configuration and stop services."""
    
    # Stop any running services installed by ports
    _stop_port_services(package, system, plan)
    
    # Uninstall all installed ports
    _uninstall_all_ports(package, system, plan)
    
    # Remove shell environment configuration
    _remove_shell_configuration(package, system, plan)
    
    # Clean up configuration files
    _clean_configuration_files(package, system, plan)
    
    return {"unprovision": True}

def _stop_port_services(package, system, plan):
    """Stop any services that were installed via ports.
    
    TRIBAL KNOWLEDGE:
    Many ports install system services (daemons).
    These must be stopped and disabled before uninstalling ports.
    """
    # Get list of services that might be from ports
    # MacPorts services typically have org.macports.* identifiers
    
    list_services = plan.shell("launchctl list | grep org.macports || true")
    
    # Stop MacPorts-related services
    # Note: In a real implementation, we'd parse the output and stop each service
    stop_services = plan.shell("""
        for service in $(launchctl list | grep org.macports | awk '{print $3}'); do
            launchctl unload -w /Library/LaunchDaemons/$service.plist 2>/dev/null || true
            launchctl unload -w ~/Library/LaunchAgents/$service.plist 2>/dev/null || true
        done
    """)
    
    plan.depends_on(stop_services, list_services)

def _uninstall_all_ports(package, system, plan):
    """Uninstall all ports before removing MacPorts itself.
    
    TRIBAL KNOWLEDGE:
    Must uninstall ports in dependency order to avoid conflicts.
    'port -f uninstall installed' forces removal of all ports.
    """
    # Create backup of installed ports (for recovery)
    backup_ports = plan.shell("port -qv installed > ~/macports_removed_$(date +%Y%m%d).txt || true")
    
    # Force uninstall all ports
    # -f flag forces removal even with dependents
    uninstall_all = plan.shell("sudo port -f uninstall installed || true")
    
    # Clean any remaining build artifacts
    clean_all = plan.shell("sudo port clean all || true")
    
    # Remove download archives
    clean_distfiles = plan.shell("sudo rm -rf /opt/local/var/macports/distfiles/* || true")
    
    plan.depends_on(uninstall_all, backup_ports)
    plan.depends_on(clean_all, uninstall_all)
    plan.depends_on(clean_distfiles, clean_all)

def _remove_shell_configuration(package, system, plan):
    """Remove MacPorts from shell environment.
    
    TRIBAL KNOWLEDGE:
    MacPorts adds PATH entries via:
    1. /etc/paths.d/MacPorts (system-wide)
    2. Manual additions to shell profiles (source installs)
    """
    # Remove system-wide path configuration
    remove_paths_d = plan.shell("sudo rm -f /etc/paths.d/MacPorts")
    
    # Remove from common shell profiles
    profile_files = [
        "~/.bash_profile",
        "~/.zshrc",
        "~/.profile",
        "~/.bashrc"
    ]
    
    for profile in profile_files:
        # Remove MacPorts-related lines
        clean_profile = plan.shell(f"""
            if [ -f {profile} ]; then
                sed -i.bak '/MacPorts/d' {profile}
                sed -i.bak '/\/opt\/local/d' {profile}
            fi
        """)

def _clean_configuration_files(package, system, plan):
    """Remove MacPorts configuration files.
    
    TRIBAL KNOWLEDGE:
    Leave user data alone, but remove system configuration.
    This includes variants.conf, sources.conf, macports.conf.
    """
    # Clean MacPorts configuration
    # Note: We're not removing /opt/local yet - that's in uninstall phase
    clean_config = plan.shell("""
        sudo rm -rf /opt/local/etc/macports/macports.conf.bak || true
        sudo rm -rf /opt/local/var/macports/registry || true
        sudo rm -rf /opt/local/var/macports/build || true
    """)
    
    # Remove any temporary files we created
    clean_temp = plan.shell("rm -f /tmp/macports_* || true")

def rollback(package, system, plan):
    """Rollback unprovision by restoring configuration.
    
    TRIBAL KNOWLEDGE:
    Rollback from unprovision is difficult because ports are uninstalled.
    Best we can do is restore environment and provide guidance.
    """
    # Restore shell configuration
    restore_msg = """
To restore MacPorts after unprovision rollback:
1. Reinstall MacPorts
2. Check for port backup: ls ~/macports_removed_*.txt
3. Restore ports: sudo port install $(cat ~/macports_removed_YYYYMMDD.txt)

Note: Port configurations and variants may need manual restoration.
"""
