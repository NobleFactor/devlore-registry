# macports/Darwin/Deploy/install.star
#
# TRIBAL KNOWLEDGE:
# MacPorts provides version-specific .pkg installers for each macOS release.
# Using the wrong version causes compatibility issues and silent failures.
# The installer automatically configures shell environment.

# Map macOS version to installer suffix
PKG_SUFFIXES = {
    "26": "26-Tahoe",
    "15": "15-Sequoia", 
    "14": "14-Sonoma",
    "13": "13-Ventura",
    "12": "12-Monterey",
    "11": "11-BigSur",
    "10": "10.15-Catalina",  # Last supported 10.x
}

def install(package, system, plan):
    """Install MacPorts via .pkg installer, source, or git."""
    
    # Check if already installed
    if system.package.installed("port"):
        return {"install": "already_installed"}
    
    # Choose installation method based on features
    if package.has_feature("install-from-git"):
        return _install_from_git(package, system, plan)
    elif package.has_feature("install-from-source"):
        return _install_from_source(package, system, plan)
    else:
        return _install_from_pkg(package, system, plan)

def _install_from_pkg(package, system, plan):
    """Install using macOS .pkg installer.
    
    TRIBAL KNOWLEDGE:
    Each macOS version requires its specific .pkg installer.
    The installer handles environment setup automatically.
    """
    # Determine correct installer based on macOS version
    os_major = system.platform.version.split(".")[0]
    
    # Handle version override from settings
    target_version = package.setting("macos-version", "auto")
    if target_version != "auto":
        os_major = target_version
    
    # Get installer suffix, default to latest if unknown
    suffix = PKG_SUFFIXES.get(os_major, "15-Sequoia")
    
    # Build installer URL
    base_url = "https://github.com/macports/macports-base/releases/download"
    pkg_url = f"{base_url}/v{package.version}/MacPorts-{package.version}-{suffix}.pkg"
    
    # Download and install .pkg
    download_node = plan.shell(f"curl -L -o /tmp/macports.pkg {pkg_url}")
    install_node = plan.shell("sudo installer -pkg /tmp/macports.pkg -target /")
    cleanup_node = plan.shell("rm -f /tmp/macports.pkg")
    
    # Ensure proper execution order
    plan.depends_on(install_node, download_node)
    plan.depends_on(cleanup_node, install_node)
    
    return {"install": True, "method": "pkg"}

def _install_from_source(package, system, plan):
    """Install from source tarball.
    
    TRIBAL KNOWLEDGE:
    Source installation allows custom prefix and configure options.
    Requires manual shell environment setup unlike .pkg installer.
    """
    tarball_url = f"https://distfiles.macports.org/MacPorts/MacPorts-{package.version}.tar.bz2"
    prefix = package.setting("prefix", "/opt/local")
    
    # Configure options
    configure_opts = f"--prefix={prefix}"
    if package.has_feature("enable-readline"):
        configure_opts += " --enable-readline"
    
    # Download and extract
    download_node = plan.shell(f"curl -L -o /tmp/macports.tar.bz2 {tarball_url}")
    extract_node = plan.shell("cd /tmp && tar xjf macports.tar.bz2")
    
    # Build and install
    configure_node = plan.shell(f"cd /tmp/MacPorts-{package.version} && ./configure {configure_opts}")
    make_node = plan.shell(f"cd /tmp/MacPorts-{package.version} && make")
    install_node = plan.shell(f"cd /tmp/MacPorts-{package.version} && sudo make install")
    
    # Cleanup
    cleanup_node = plan.shell(f"rm -rf /tmp/macports.tar.bz2 /tmp/MacPorts-{package.version}")
    
    # Chain dependencies
    plan.depends_on(extract_node, download_node)
    plan.depends_on(configure_node, extract_node)
    plan.depends_on(make_node, configure_node)
    plan.depends_on(install_node, make_node)
    plan.depends_on(cleanup_node, install_node)
    
    return {"install": True, "method": "source"}

def _install_from_git(package, system, plan):
    """Install from git repository (development version).
    
    TRIBAL KNOWLEDGE:
    Git installation gets the absolute latest code.
    Use specific tag for reproducible builds.
    """
    repo_url = "https://github.com/macports/macports-base.git"
    prefix = package.setting("prefix", "/opt/local")
    
    # Configure options
    configure_opts = f"--prefix={prefix}"
    if package.has_feature("enable-readline"):
        configure_opts += " --enable-readline"
    
    # Clone and checkout specific version
    clone_node = plan.shell(f"git clone {repo_url} /tmp/macports-base")
    checkout_node = plan.shell(f"cd /tmp/macports-base && git checkout v{package.version}")
    
    # Build and install 
    configure_node = plan.shell(f"cd /tmp/macports-base && ./configure {configure_opts}")
    make_node = plan.shell("cd /tmp/macports-base && make")
    install_node = plan.shell("cd /tmp/macports-base && sudo make install")
    
    # Cleanup
    cleanup_node = plan.shell("rm -rf /tmp/macports-base")
    
    # Chain dependencies
    plan.depends_on(checkout_node, clone_node)
    plan.depends_on(configure_node, checkout_node)
    plan.depends_on(make_node, configure_node)
    plan.depends_on(install_node, make_node)
    plan.depends_on(cleanup_node, install_node)
    
    return {"install": True, "method": "git"}

def rollback(package, system, plan):
    """Remove MacPorts installation if install fails."""
    # Remove MacPorts installation
    plan.shell("sudo rm -rf /opt/local")
    plan.shell("sudo rm -rf /Applications/MacPorts")
    
    # Remove user/group if created
    plan.shell("sudo dscl . -delete /Users/macports 2>/dev/null || true")
    plan.shell("sudo dscl . -delete /Groups/macports 2>/dev/null || true")
