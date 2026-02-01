# macports/Darwin/Deploy/provision.star - Provision phase for MacPorts
#
# TRIBAL KNOWLEDGE:
# The .pkg installer automatically configures shell environment via postflight
# scripts, but source installations require manual PATH setup. Xcode license
# acceptance is critical - without it, ports that need to compile will fail
# with cryptic errors about missing tools.

def provision():
    """Configure MacPorts for use."""
    _setup_shell_environment()
    _accept_xcode_license()
    _initial_selfupdate()
    return {"provision": True}

def _setup_shell_environment():
    """Configure PATH and MANPATH for MacPorts."""
    install_from_source = env.get("LORE_FEATURE_INSTALL_FROM_SOURCE", "false") == "true"
    install_prefix = env.get("LORE_SETTING_INSTALL_PREFIX", "/opt/local")
    
    # .pkg installer handles this automatically, but source installs need manual setup
    if install_from_source:
        _configure_shell_profile(install_prefix)
    
    # Verify PATH is configured correctly
    port_path = f"{install_prefix}/bin/port"
    if not fs.which("port") and fs.exists(port_path):
        print("WARNING: MacPorts not in PATH. You may need to restart your shell or run:")
        print(f"  export PATH={install_prefix}/bin:{install_prefix}/sbin:$PATH")

def _configure_shell_profile(install_prefix):
    """Add MacPorts to shell profile for source installations."""
    path_line = f"export PATH={install_prefix}/bin:{install_prefix}/sbin:$PATH"
    manpath_line = f"export MANPATH={install_prefix}/share/man:$MANPATH"
    
    # Detect shell and configure appropriate profile
    user_shell = env.get("SHELL", "/bin/bash")
    
    if "zsh" in user_shell:
        profile_file = env.expand("~/.zshrc")
    elif "bash" in user_shell:
        profile_file = env.expand("~/.bash_profile")
    else:
        profile_file = env.expand("~/.profile")
    
    # Check if already configured
    if fs.exists(profile_file):
        content = fs.read(profile_file)
        if install_prefix in content:
            return  # Already configured
    
    # Add MacPorts configuration
    fs.write(profile_file, f"\n# MacPorts\n{path_line}\n{manpath_line}\n", append=True)
    print(f"Added MacPorts to {profile_file}")

def _accept_xcode_license():
    """Accept Xcode license if needed."""
    auto_accept = env.get("LORE_FEATURE_AUTO_ACCEPT_XCODE_LICENSE", "true") == "true"
    
    if not auto_accept:
        return
    
    # Check if license needs to be accepted
    result = shell.exec(
        "xcodebuild -license check",
        allowed_commands=["xcodebuild"]
    )
    
    if not result.success:
        print("Accepting Xcode license...")
        shell.exec(
            "sudo xcodebuild -license accept",
            allowed_commands=["xcodebuild"]
        )
        print("Xcode license accepted")

def _initial_selfupdate():
    """Perform initial sync with MacPorts repository."""
    if not fs.exists("/opt/local/bin/port"):
        fail("MacPorts not found at expected location")
    
    print("Performing initial MacPorts sync...")
    result = shell.exec(
        "sudo port -v selfupdate",
        allowed_commands=["port"]
    )
    
    if not result.success:
        print("WARNING: Initial selfupdate failed. You may need to run this manually:")
        print("  sudo port -v selfupdate")
    else:
        print("MacPorts sync completed successfully")

def rollback():
    """Remove MacPorts shell configuration."""
    install_from_source = env.get("LORE_FEATURE_INSTALL_FROM_SOURCE", "false") == "true"
    
    if install_from_source:
        install_prefix = env.get("LORE_SETTING_INSTALL_PREFIX", "/opt/local")
        
        # Remove from shell profiles
        profile_files = [
            env.expand("~/.zshrc"),
            env.expand("~/.bash_profile"),
            env.expand("~/.profile")
        ]
        
        for profile in profile_files:
            if fs.exists(profile):
                content = fs.read(profile)
                # Remove MacPorts section
                lines = content.split('\n')
                new_lines = []
                skip_macports = False
                
                for line in lines:
                    if line.strip() == "# MacPorts":
                        skip_macports = True
                        continue
                    elif skip_macports and (install_prefix in line or line.strip() == ""):
                        continue
                    else:
                        skip_macports = False
                        new_lines.append(line)
                
                fs.write(profile, '\n'.join(new_lines))
