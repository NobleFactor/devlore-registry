# macports/Darwin/Upgrade/migrate.star
#
# TRIBAL KNOWLEDGE:
# MacPorts installations don't survive major macOS upgrades or architecture
# changes. The 'port migrate' command (available in 2.10.0+) automates
# rebuilding all installed ports for the new system. This is essential
# after OS upgrades to ensure binary compatibility.

def migrate(package, system, plan):
    """Run MacPorts migration to rebuild ports for new system."""
    
    # First, update MacPorts itself and the ports tree
    selfupdate = plan.shell("sudo port -v selfupdate")
    
    # Run migration (requires MacPorts 2.10.0+)
    migrate_ports = plan.shell("sudo port migrate")
    
    # If migrate fails or isn't available, fall back to manual reinstall
    # This would check if installed ports list exists from prepare phase
    manual_reinstall = plan.shell(
        "if [ -f /tmp/macports-installed.txt ]; then " +
        "sudo port install $(cat /tmp/macports-installed.txt | awk '{print $1}' | tr '\n' ' '); " +
        "fi"
    )
    
    # Dependencies - try migrate first, then manual if needed
    plan.depends_on(migrate_ports, selfupdate)
    # manual_reinstall would only run if migrate_ports fails
    
    return {"migrate": True}

def rollback(package, system, plan):
    """Clean up migration artifacts."""
    plan.shell("rm -f /tmp/macports-installed.txt")
    return {"rollback": True}

