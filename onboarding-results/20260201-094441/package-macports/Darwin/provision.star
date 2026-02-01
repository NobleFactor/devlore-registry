# macports/Darwin/provision.star - Provision phase for MacPorts on macOS
#
# TRIBAL KNOWLEDGE:
# The .pkg installer automatically adds MacPorts to PATH via shell profiles,
# but changes don't take effect until you open a new shell session.
# Source installations require manual PATH configuration.

def provision():
    """Configure MacPorts for use."""
    _setup_shell_environment()
    _configure_macports()
    _initial_selfupdate()
    _setup_x11_if_requested()
    return {"provision": True}

def _setup_shell_environment():
    """Ensure MacPorts is in PATH."""
    prefix = "/opt/local"  # Standard for pkg installer
    
    # For source installations, use configured prefix
    if config.get("features.source-install", False):
        prefix = config.get("settings.install-prefix", "/opt/local")
    
    # TRIBAL KNOWLEDGE:
    # The .pkg installer adds a /etc/paths.d/MacPorts file, but we should
    # verify it exists and is correct
    macports_path_file = "/etc/paths.d/MacPorts"
    expected_content = f"{prefix}/bin\n{prefix}/sbin"
    
    if not fs.exists(macports_path_file):
        print("Creating MacPorts PATH configuration...")
        shell.exec(
            f"echo '{expected_content}' | sudo tee {macports_path_file}",
            allowed_commands=["tee"],
        )
    
    # Also ensure current session can find port command
    current_path = env.get("PATH", "")
    if f"{prefix}/bin" not in current_path:
        env.set("PATH", f"{prefix}/bin:{prefix}/sbin:{current_path}")

def _configure_macports():
    """Configure MacPorts settings."""
    config_file = "/opt/local/etc/macports/macports.conf"
    
    if not fs.exists(config_file):
        return  # No config file to modify
    
    # TRIBAL KNOWLEDGE:
    # On Apple Silicon, we may want to ensure universal_archs is set correctly
    # for compatibility with x86_64 software
    if platform.arch == "arm64":
        _ensure_universal_archs_config(config_file)

def _ensure_universal_archs_config(config_file):
    """Ensure universal_archs is set appropriately for Apple Silicon."""
    config_content = fs.read(config_file)
    
    # Check if universal_archs is already configured
    if "universal_archs" not in config_content:
        # Add recommended universal_archs for Apple Silicon
        addition = "\n# Universal architectures for Apple Silicon compatibility\nuniversal_archs arm64 x86_64\n"
        fs.write(config_file, config_content + addition)
        print("Configured universal architectures for Apple Silicon")

def _initial_selfupdate():
    """Run initial selfupdate to sync ports tree."""
    print("Running initial MacPorts selfupdate...")
    
    # TRIBAL KNOWLEDGE:
    # First selfupdate after installation is critical - it downloads
    # the current ports tree. Without this, no ports can be installed.
    shell.exec(
        "sudo /opt/local/bin/port -v selfupdate",
        allowed_commands=["port"],
    )
    
    print("MacPorts is ready to use!")
    print("You may need to open a new terminal for PATH changes to take effect.")

def _setup_x11_if_requested():
    """Install X11 support if requested."""
    if not config.get("features.x11-support", False):
        return
    
    print("Installing X11 windowing environment support...")
    
    # TRIBAL KNOWLEDGE:
    # MacPorts recommends installing xorg-server from ports rather than
    # using XQuartz, as it's better integrated with the MacPorts ecosystem
    shell.exec(
        "sudo /opt/local/bin/port install xorg-server",
        allowed_commands=["port"],
    )
    
    print("X11 support installed via xorg-server port")

def rollback():
    """Remove MacPorts configuration."""
    # Remove PATH configuration
    if fs.exists("/etc/paths.d/MacPorts"):
        shell.exec(
            "sudo rm /etc/paths.d/MacPorts",
            allowed_commands=["rm"],
        )
    
    # Remove any shell profile modifications (conservative approach)
    # The pkg installer may have modified ~/.bash_profile, ~/.zshrc, etc.
    # We'll just notify the user rather than trying to automatically revert
    print("Note: You may want to check ~/.bash_profile, ~/.zshrc for MacPorts entries")
