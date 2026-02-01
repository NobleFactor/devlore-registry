# macports/Darwin/provision.star - Provision phase for MacPorts on macOS
#
# TRIBAL KNOWLEDGE:
# The .pkg installer automatically modifies shell configuration files,
# but source installs require manual PATH setup. Users often miss this
# step and then can't find the 'port' command.

def provision():
    """Configure MacPorts for use."""
    _setup_shell_environment()
    _configure_features()
    return {"provision": True}

def _setup_shell_environment():
    """Ensure MacPorts is in PATH."""
    # TRIBAL KNOWLEDGE: .pkg installer handles this automatically
    # Source installs require manual PATH modification
    port_path = "/opt/local/bin/port"
    if not fs.exists(port_path):
        return
    
    # Check if already in PATH
    result = shell.exec(
        "which port",
        allowed_commands=["which"],
    )
    if result.exit_code == 0:
        return  # Already configured
    
    # Add to shell profiles
    shell_configs = [
        env.expand("$HOME/.bash_profile"),
        env.expand("$HOME/.zshrc"),
    ]
    
    path_export = 'export PATH="/opt/local/bin:/opt/local/sbin:$PATH"\n'
    manpath_export = 'export MANPATH="/opt/local/share/man:$MANPATH"\n'
    
    for config_file in shell_configs:
        if fs.exists(config_file):
            content = fs.read(config_file)
            if "/opt/local/bin" not in content:
                fs.write(config_file, content + "\n" + path_export + manpath_export)

def _configure_features():
    """Configure requested features."""
    config_file = "/opt/local/etc/macports/macports.conf"
    if not fs.exists(config_file):
        return
    
    # Read current config
    content = fs.read(config_file)
    modified = False
    
    # Configure build jobs if specified
    if hasattr(env, "MACPORTS_BUILD_JOBS"):
        jobs = env.get("MACPORTS_BUILD_JOBS")
        if f"buildmakejobs {jobs}" not in content:
            content += f"\nbuildmakejobs {jobs}\n"
            modified = True
    
    # Configure universal builds if requested
    if env.get("MACPORTS_UNIVERSAL", "false") == "true":
        if "universal_archs" not in content:
            if platform.arch == "arm64":
                content += "\nuniversal_archs arm64 x86_64\n"
            else:
                content += "\nuniversal_archs x86_64 i386\n"
            modified = True
    
    if modified:
        fs.write(config_file, content)

def rollback():
    """Remove shell environment modifications."""
    shell_configs = [
        env.expand("$HOME/.bash_profile"),
        env.expand("$HOME/.zshrc"),
    ]
    
    for config_file in shell_configs:
        if fs.exists(config_file):
            content = fs.read(config_file)
            # Remove MacPorts PATH exports
            lines = content.split("\n")
            filtered_lines = [
                line for line in lines 
                if "/opt/local/bin" not in line and "/opt/local/share/man" not in line
            ]
            fs.write(config_file, "\n".join(filtered_lines))

