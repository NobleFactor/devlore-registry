# macports/Darwin/Deploy/provision.star
#
# TRIBAL KNOWLEDGE:
# The .pkg installer automatically configures shell environment,
# but source/git installs require manual PATH and MANPATH setup.
# New terminal required for changes to take effect.

def provision(package, system, plan):
    """Configure MacPorts environment and perform initial setup."""
    
    # Configure shell environment if needed
    _configure_shell_environment(package, system, plan)
    
    # Perform initial selfupdate
    _initial_selfupdate(package, system, plan)
    
    # Configure variants and build settings if specified
    _configure_build_settings(package, system, plan)
    
    return {"provision": True}

def _configure_shell_environment(package, system, plan):
    """Configure shell PATH and MANPATH.
    
    TRIBAL KNOWLEDGE:
    .pkg installer automatically adds MacPorts paths via /etc/paths.d/MacPorts.
    Source installs need manual configuration in shell profiles.
    Changes require new terminal session to take effect.
    """
    prefix = package.setting("prefix", "/opt/local")
    
    # Check if we installed from source (needs manual env setup)
    # The .pkg installer handles this automatically
    paths_file = "/etc/paths.d/MacPorts"
    
    # If paths.d entry doesn't exist, we likely installed from source
    check_paths = plan.shell(f"test -f {paths_file}")
    
    # Configure shell profiles for source installs
    env_setup = f"""
# MacPorts environment setup
export PATH={prefix}/bin:{prefix}/sbin:$PATH
export MANPATH={prefix}/share/man:$MANPATH
"""
    
    # Add to common shell profiles
    profile_files = [
        "~/.bash_profile",
        "~/.zshrc", 
        "~/.profile"
    ]
    
    for profile in profile_files:
        # Only add if file exists and doesn't already contain MacPorts config
        check_profile = plan.shell(f"test -f {profile} && ! grep -q 'MacPorts' {profile}")
        add_config = plan.file.write(profile, env_setup, mode="append")
        plan.depends_on(add_config, check_profile)

def _initial_selfupdate(package, system, plan):
    """Perform initial selfupdate to get latest ports tree.
    
    TRIBAL KNOWLEDGE:
    selfupdate is essential after installation to get current ports tree
    and any base system updates. This prevents stale package information.
    """
    # Run selfupdate to get latest ports and MacPorts base
    selfupdate_node = plan.shell("sudo /opt/local/bin/port -v selfupdate")
    
    # Update command may take several minutes, add timeout consideration
    # Note: In real implementation, we'd want longer timeout for this operation

def _configure_build_settings(package, system, plan):
    """Configure MacPorts build variants and settings.
    
    TRIBAL KNOWLEDGE:
    Default variants can be set globally in /opt/local/etc/macports/variants.conf
    Build settings in /opt/local/etc/macports/macports.conf affect all ports.
    """
    prefix = package.setting("prefix", "/opt/local")
    
    # Example: Configure default variants
    # This could be extended based on package settings
    variants_config = """
# Default variants for all ports
+universal
"""
    
    # Only configure if variants.conf doesn't exist
    variants_file = f"{prefix}/etc/macports/variants.conf"
    check_variants = plan.shell(f"test ! -f {variants_file}")
    write_variants = plan.file.write(variants_file, variants_config)
    plan.depends_on(write_variants, check_variants)

def rollback(package, system, plan):
    """Remove MacPorts configuration from shell profiles."""
    profile_files = [
        "~/.bash_profile",
        "~/.zshrc",
        "~/.profile"
    ]
    
    # Remove MacPorts configuration lines
    for profile in profile_files:
        plan.shell(f"sed -i '' '/MacPorts environment setup/,+2d' {profile} 2>/dev/null || true")
