# macports/Darwin/Decommission/unprovision.star - Unprovision phase for MacPorts

def unprovision():
    """Remove MacPorts configuration and stop services."""
    _remove_shell_configuration()
    _stop_macports_services()
    return {"unprovision": True}

def _remove_shell_configuration():
    """Remove MacPorts from shell profiles."""
    profile_files = [
        env.expand("~/.zshrc"),
        env.expand("~/.bash_profile"),
        env.expand("~/.profile")
    ]
    
    for profile in profile_files:
        if fs.exists(profile):
            _clean_profile_file(profile)

def _clean_profile_file(profile_path):
    """Remove MacPorts entries from a shell profile file."""
    content = fs.read(profile_path)
    lines = content.split('\n')
    new_lines = []
    skip_macports = False
    
    for line in lines:
        if line.strip() == "# MacPorts":
            skip_macports = True
            continue
        elif skip_macports and ("/opt/local" in line or line.strip() == ""):
            if line.strip() != "":
                continue
        else:
            skip_macports = False
        
        new_lines.append(line)
    
    # Remove trailing empty lines
    while new_lines and new_lines[-1].strip() == "":
        new_lines.pop()
    
    fs.write(profile_path, '\n'.join(new_lines))
    print(f"Removed MacPorts configuration from {profile_path}")

def _stop_macports_services():
    """Stop any MacPorts-managed services."""
    # Get list of active MacPorts services
    result = shell.exec(
        "port -q installed | grep active",
        allowed_commands=["port", "grep"]
    )
    
    if result.success and result.stdout.strip():
        print("Stopping MacPorts services...")
        # Note: This is a simplified approach
        # In practice, each service would need individual handling
        shell.exec(
            "sudo port unload installed",
            allowed_commands=["port"]
        )

def rollback():
    """Restore MacPorts configuration."""
    print("Restoring MacPorts shell configuration...")
    install_prefix = "/opt/local"
    
    # Re-add to primary shell profile
    user_shell = env.get("SHELL", "/bin/bash")
    if "zsh" in user_shell:
        profile_file = env.expand("~/.zshrc")
    else:
        profile_file = env.expand("~/.bash_profile")
    
    path_line = f"export PATH={install_prefix}/bin:{install_prefix}/sbin:$PATH"
    manpath_line = f"export MANPATH={install_prefix}/share/man:$MANPATH"
    
    fs.write(profile_file, f"\n# MacPorts\n{path_line}\n{manpath_line}\n", append=True)
