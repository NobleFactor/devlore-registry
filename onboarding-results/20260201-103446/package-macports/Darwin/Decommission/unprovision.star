# macports/Darwin/Decommission/unprovision.star

def unprovision(package, system, plan):
    """Remove MacPorts environment configuration."""
    
    # Remove shell configuration
    remove_zsh_config = plan.shell(f"rm -f {package.target_root}/.zprofile.macports")
    remove_bash_config = plan.shell(f"rm -f {package.target_root}/.bash_profile.macports")
    
    # Remove source lines from shell configs
    clean_zprofile = plan.shell(f"sed -i '' '/source.*macports/d' {package.target_root}/.zprofile 2>/dev/null || true")
    clean_bash_profile = plan.shell(f"sed -i '' '/source.*macports/d' {package.target_root}/.bash_profile 2>/dev/null || true")
    
    # Remove any automatically added PATH modifications
    clean_zsh_path = plan.shell(f"sed -i '' '/\/opt\/local\/bin/d' {package.target_root}/.zprofile 2>/dev/null || true")
    clean_bash_path = plan.shell(f"sed -i '' '/\/opt\/local\/bin/d' {package.target_root}/.bash_profile 2>/dev/null || true")
    
    return {"unprovision": True}

def rollback(package, system, plan):
    """No rollback needed for unprovision."""
    return {"rollback": True}

