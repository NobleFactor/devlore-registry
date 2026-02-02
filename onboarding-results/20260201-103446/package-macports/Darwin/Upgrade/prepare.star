# macports/Darwin/Upgrade/prepare.star

def prepare(package, system, plan):
    """Prepare for MacPorts upgrade."""
    
    # Check current installation
    if not system.package.installed("port"):
        return {"prepare": False, "error": "MacPorts not currently installed"}
    
    # Backup current configuration
    backup_config = plan.shell("sudo cp -R /opt/local/etc/macports /tmp/macports-config-backup")
    
    # Export list of installed ports
    export_ports = plan.shell("port -qv installed > /tmp/macports-installed.txt")
    
    plan.depends_on(export_ports, backup_config)
    
    return {"prepare": True}

def rollback(package, system, plan):
    """Restore from backup if upgrade preparation fails."""
    plan.shell("sudo rm -rf /tmp/macports-config-backup /tmp/macports-installed.txt")
    return {"rollback": True}

