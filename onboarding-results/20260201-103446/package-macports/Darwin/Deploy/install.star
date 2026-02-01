# macports/Darwin/Deploy/install.star
#
# TRIBAL KNOWLEDGE:
# MacPorts provides version-specific .pkg installers for each macOS release.
# Using the wrong version causes compatibility issues with system libraries.
# The installer URLs follow a predictable pattern with OS codenames.

# Map macOS major version to installer suffix
PKG_SUFFIXES = {
    "26": "26-Tahoe",
    "15": "15-Sequoia", 
    "14": "14-Sonoma",
    "13": "13-Ventura",
    "12": "12-Monterey",
    "11": "11-BigSur",
    "10": "10-Catalina",
}

def install(package, system, plan):
    """Install MacPorts via .pkg installer, source, or git."""
    
    # Check if already installed
    if system.package.installed("port"):
        current_version = system.package.version("port")
        if current_version == package.version:
            return {"install": "already_installed"}
    
    # Choose installation method based on features
    if package.has_feature("install-from-git"):
        return _install_from_git(package, system, plan)
    elif package.has_feature("install-from-source"):
        return _install_from_source(package, system, plan)
    else:
        return _install_from_pkg(package, system, plan)

def _install_from_pkg(package, system, plan):
    """Install MacPorts using version-specific .pkg installer."""
    
    # Determine installer URL based on macOS version
    macos_version = package.setting("macos-version", "auto")
    if macos_version == "auto":
        os_version = system.platform.version
        os_major = os_version.split(".")[0]
    else:
        os_major = macos_version
    
    # Get appropriate suffix or default to latest
    suffix = PKG_SUFFIXES.get(os_major, "15-Sequoia")
    
    pkg_url = f"https://github.com/macports/macports-base/releases/download/v{package.version}/MacPorts-{package.version}-{suffix}.pkg"
    
    # Build execution graph
    download = plan.shell(f"curl -L -o /tmp/macports.pkg {pkg_url}")
    install_pkg = plan.shell("sudo installer -pkg /tmp/macports.pkg -target /")
    cleanup = plan.shell("rm -f /tmp/macports.pkg")
    
    # Declare execution order
    plan.depends_on(install_pkg, download)
    plan.depends_on(cleanup, install_pkg)
    
    return {"install": True}

def _install_from_source(package, system, plan):
    """Install MacPorts from source tarball."""
    
    prefix = package.setting("prefix", "/opt/local")
    configure_args = package.setting("configure-args", "")
    
    tarball_url = f"https://distfiles.macports.org/MacPorts/MacPorts-{package.version}.tar.bz2"
    
    # Download and extract
    download = plan.shell(f"curl -L -o /tmp/macports.tar.bz2 {tarball_url}")
    extract = plan.shell("cd /tmp && tar -xjf macports.tar.bz2")
    
    # Configure, build, install
    configure = plan.shell(f"cd /tmp/MacPorts-{package.version} && ./configure --prefix={prefix} {configure_args}")
    make = plan.shell(f"cd /tmp/MacPorts-{package.version} && make")
    install = plan.shell(f"cd /tmp/MacPorts-{package.version} && sudo make install")
    
    # Cleanup
    cleanup = plan.shell(f"rm -rf /tmp/MacPorts-{package.version} /tmp/macports.tar.bz2")
    
    # Dependencies
    plan.depends_on(extract, download)
    plan.depends_on(configure, extract)
    plan.depends_on(make, configure)
    plan.depends_on(install, make)
    plan.depends_on(cleanup, install)
    
    return {"install": True}

def _install_from_git(package, system, plan):
    """Install MacPorts from Git HEAD."""
    
    prefix = package.setting("prefix", "/opt/local")
    configure_args = package.setting("configure-args", "")
    
    # Clone repository
    clone = plan.shell("git clone https://github.com/macports/macports-base.git /tmp/macports-git")
    
    # Generate configure script and build
    autoreconf = plan.shell("cd /tmp/macports-git && autoreconf -fvi")
    configure = plan.shell(f"cd /tmp/macports-git && ./configure --prefix={prefix} {configure_args}")
    make = plan.shell("cd /tmp/macports-git && make")
    install = plan.shell("cd /tmp/macports-git && sudo make install")
    
    # Cleanup
    cleanup = plan.shell("rm -rf /tmp/macports-git")
    
    # Dependencies
    plan.depends_on(autoreconf, clone)
    plan.depends_on(configure, autoreconf)
    plan.depends_on(make, configure)
    plan.depends_on(install, make)
    plan.depends_on(cleanup, install)
    
    return {"install": True}

def rollback(package, system, plan):
    """Remove MacPorts if installation fails."""
    plan.shell("sudo rm -rf /opt/local")
    plan.shell("sudo rm -rf /Applications/MacPorts")
    plan.shell("sudo dscl . -delete /Users/macports 2>/dev/null || true")
    plan.shell("sudo dscl . -delete /Groups/macports 2>/dev/null || true")
    return {"rollback": True}

