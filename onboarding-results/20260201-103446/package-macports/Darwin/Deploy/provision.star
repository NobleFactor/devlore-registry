# macports/Darwin/Deploy/provision.star
#
# TRIBAL KNOWLEDGE:
# The .pkg installer automatically modifies shell configuration files
# (.zprofile, .profile) to set PATH and MANPATH. Source installations
# require manual shell setup. This ensures MacPorts binaries take
# precedence over system versions.

def provision(package, system, plan):
    """Configure MacPorts environment and PATH setup."""
    
    # For .pkg installs, shell setup is automatic
    if not package.has_feature("install-from-source") and not package.has_feature("install-from-git"):
        return _provision_pkg_install(package, system, plan)
    else:
        return _provision_source_install(package, system, plan)

def _provision_pkg_install(package, system, plan):
    """Provision for .pkg installer (minimal setup needed)."""
    # .pkg installer handles shell configuration automatically
    # Just verify the setup worked
    verify_path = plan.shell("echo $PATH | grep -q /opt/local/bin")
    
    return {"provision": True}

def _provision_source_install(package, system, plan):
    """Provision for source installation (manual shell setup required)."""
    
    prefix = package.setting("prefix", "/opt/local")
    
    # Detect user's shell
    detect_shell = plan.shell("basename $SHELL")
    
    # Add PATH and MANPATH to appropriate shell configuration files
    # For zsh (default on macOS 10.15+)
    zsh_config = f"""# MacPorts environment setup
export PATH="{prefix}/bin:{prefix}/sbin:$PATH"
export MANPATH="{prefix}/share/man:$MANPATH"
"""
    
    add_to_zprofile = plan.file.write(f"{package.target_root}/.zprofile.macports", zsh_config)
    append_zprofile = plan.shell(f"echo 'source ~/.zprofile.macports' >> {package.target_root}/.zprofile")
    
    # For bash
    bash_config = f"""# MacPorts environment setup
export PATH="{prefix}/bin:{prefix}/sbin:$PATH"
export MANPATH="{prefix}/share/man:$MANPATH"
"""
    
    add_to_bash_profile = plan.file.write(f"{package.target_root}/.bash_profile.macports", bash_config)
    append_bash_profile = plan.shell(f"echo 'source ~/.bash_profile.macports' >> {package.target_root}/.bash_profile")
    
    # Dependencies
    plan.depends_on(append_zprofile, add_to_zprofile)
    plan.depends_on(append_bash_profile, add_to_bash_profile)
    
    return {"provision": True}

def rollback(package, system, plan):
    """Remove shell configuration changes."""
    
    # Remove our configuration files
    plan.shell(f"rm -f {package.target_root}/.zprofile.macports")
    plan.shell(f"rm -f {package.target_root}/.bash_profile.macports")
    
    # Remove source lines from shell configs (best effort)
    plan.shell(f"sed -i '' '/source.*macports/d' {package.target_root}/.zprofile 2>/dev/null || true")
    plan.shell(f"sed -i '' '/source.*macports/d' {package.target_root}/.bash_profile 2>/dev/null || true")
    
    return {"rollback": True}

