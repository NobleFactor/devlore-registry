# macports/Darwin/Upgrade/upgrade.star
#
# TRIBAL KNOWLEDGE:
# MacPorts upgrades involve both base system upgrade and selfupdate.
# The order matters: base first, then selfupdate to get latest ports tree.

def upgrade(package, system, plan):
    """Upgrade MacPorts base and perform selfupdate."""
    
    current_version = system.package.version("port")
    target_version = package.version
    
    if current_version == target_version:
        return {"upgrade": "already_current"}
    
    # Determine upgrade method based on installation type
    upgrade_method = _determine_upgrade_method(package, system, plan)
    
    if upgrade_method == "pkg":
        result = _upgrade_via_pkg(package, system, plan)
    elif upgrade_method == "selfupdate":
        result = _upgrade_via_selfupdate(package, system, plan)
    else:
        result = _upgrade_via_reinstall(package, system, plan)
    
    return result

def _determine_upgrade_method(package, system, plan):
    """Determine best upgrade method.
    
    TRIBAL KNOWLEDGE:
    - selfupdate works for minor version bumps
    - Major versions or OS upgrades often need .pkg reinstall
    - Development installs (git) need manual upgrade
    """
    current_version = system.package.version("port")
    target_version = package.version
    
    current_major = int(current_version.split(".")[0])
    target_major = int(target_version.split(".")[0])
    
    current_minor = int(current_version.split(".")[1])
    target_minor = int(target_version.split(".")[1])
    
    # Major version change needs pkg reinstall
    if current_major != target_major:
        return "pkg"
    
    # Minor version change can use selfupdate if available
    if current_minor != target_minor:
        # Check if target version is available via selfupdate
        return "selfupdate"
    
    # Patch level updates via selfupdate
    return "selfupdate"

def _upgrade_via_selfupdate(package, system, plan):
    """Upgrade using selfupdate mechanism.
    
    TRIBAL KNOWLEDGE:
    selfupdate upgrades both MacPorts base and ports tree.
    This is the preferred method for same major.minor versions.
    """
    # Backup current installation state
    backup_node = plan.shell("port -qv installed > /tmp/macports_backup_$(date +%Y%m%d).txt")
    
    # Perform selfupdate
    selfupdate_node = plan.shell("sudo port -d selfupdate")
    
    # Verify upgrade succeeded
    verify_node = plan.shell(f"port version | grep -q '{package.version}'")
    
    # Chain operations
    plan.depends_on(selfupdate_node, backup_node)
    plan.depends_on(verify_node, selfupdate_node)
    
    return {"upgrade": True, "method": "selfupdate"}

def _upgrade_via_pkg(package, system, plan):
    """Upgrade using .pkg installer.
    
    TRIBAL KNOWLEDGE:
    .pkg installer upgrade preserves existing ports but updates base.
    This is safest for major version upgrades.
    """
    # Import the install logic from Deploy operation
    from Darwin.Deploy.install import _install_from_pkg
    
    # Backup installed ports list
    backup_node = plan.shell("port -qv installed > /tmp/macports_backup_$(date +%Y%m%d).txt")
    
    # Use same .pkg installation logic
    install_result = _install_from_pkg(package, system, plan)
    
    # The .pkg installer handles the upgrade automatically
    return {"upgrade": True, "method": "pkg"}

def _upgrade_via_reinstall(package, system, plan):
    """Upgrade by complete reinstall.
    
    TRIBAL KNOWLEDGE:
    Sometimes needed for git installs or corrupted installations.
    Requires careful backup and restore of ports.
    """
    # Export list of installed ports with variants
    export_node = plan.shell("port -qv installed > /tmp/macports_ports_backup.txt")
    
    # Export manually installed (requested) ports only
    requested_node = plan.shell("port echo requested > /tmp/macports_requested_backup.txt")
    
    # Remove current installation (this is drastic!)
    remove_node = plan.shell("sudo rm -rf /opt/local")
    
    # Reinstall MacPorts base
    from Darwin.Deploy.install import install as deploy_install
    install_result = deploy_install(package, system, plan)
    
    # Note: Port restoration will happen in migrate phase
    
    plan.depends_on(requested_node, export_node)
    plan.depends_on(remove_node, requested_node)
    
    return {"upgrade": True, "method": "reinstall"}

def rollback(package, system, plan):
    """Rollback failed upgrade.
    
    TRIBAL KNOWLEDGE:
    MacPorts upgrades are hard to rollback cleanly.
    Best approach is to restore from backup if available.
    """
    # Check if backup exists
    backup_check = plan.shell("ls /tmp/macports_backup_*.txt 2>/dev/null")
    
    # If backup exists, we could theoretically restore
    # But this is complex - in practice, clean reinstall is often easier
    
    rollback_msg = """
MacPorts upgrade rollback is complex.
Consider clean reinstall if system is unstable:
  1. sudo rm -rf /opt/local
  2. Reinstall MacPorts from .pkg
  3. Restore ports from backup: sudo port install $(cat backup.txt)
"""
