# macports/Darwin/Deploy/install.star - Install phase for MacPorts
#
# TRIBAL KNOWLEDGE:
# MacPorts provides version-specific .pkg installers for each macOS release.
# Using the wrong version can cause compatibility issues. The pkg installer
# is strongly preferred over source installation because it handles shell
# environment setup automatically via postflight scripts.

# Version-specific installer URLs
PKG_INSTALLERS = {
    "26": "MacPorts-2.11.6-26-Tahoe.pkg",
    "15": "MacPorts-2.11.6-15-Sequoia.pkg", 
    "14": "MacPorts-2.11.6-14-Sonoma.pkg",
    "13": "MacPorts-2.11.6-13-Ventura.pkg",
    "12": "MacPorts-2.11.6-12-Monterey.pkg",
    "11": "MacPorts-2.11.6-11-BigSur.pkg",
    "10.15": "MacPorts-2.11.6-10.15-Catalina.pkg",
    "10.14": "MacPorts-2.11.6-10.14-Mojave.pkg",
    "10.13": "MacPorts-2.11.6-10.13-HighSierra.pkg",
    "10.12": "MacPorts-2.11.6-10.12-Sierra.pkg"
}

BASE_URL = "https://distfiles.macports.org/MacPorts"
SOURCE_URL = "https://distfiles.macports.org/MacPorts/MacPorts-2.11.6.tar.bz2"

def install():
    """Install MacPorts via .pkg installer or from source."""
    install_from_source = env.get("LORE_FEATURE_INSTALL_FROM_SOURCE", "false") == "true"
    
    if install_from_source:
        _install_from_source()
    else:
        _install_from_pkg()
    
    return {"install": True}

def _install_from_pkg():
    """Install using macOS .pkg installer."""
    macos_version = _get_macos_version()
    pkg_filename = _get_pkg_for_version(macos_version)
    
    if not pkg_filename:
        fail(f"No MacPorts .pkg installer available for macOS {macos_version}")
    
    pkg_url = f"{BASE_URL}/{pkg_filename}"
    temp_path = f"/tmp/{pkg_filename}"
    
    print(f"Downloading MacPorts installer for macOS {macos_version}...")
    http.download(pkg_url, temp_path)
    
    print("Installing MacPorts...")
    shell.exec(
        f"sudo installer -pkg {temp_path} -target /",
        allowed_commands=["installer"]
    )
    
    # Cleanup
    fs.remove(temp_path)

def _install_from_source():
    """Install from source tarball."""
    enable_readline = env.get("LORE_FEATURE_ENABLE_READLINE", "true") == "true"
    install_prefix = env.get("LORE_SETTING_INSTALL_PREFIX", "/opt/local")
    
    temp_dir = "/tmp/macports-source"
    tarball_path = f"{temp_dir}/MacPorts-2.11.6.tar.bz2"
    
    fs.mkdir(temp_dir)
    
    print("Downloading MacPorts source...")
    http.download(SOURCE_URL, tarball_path)
    
    print("Extracting source...")
    archive.extract(tarball_path, temp_dir)
    
    source_dir = f"{temp_dir}/MacPorts-2.11.6"
    
    # Configure
    configure_args = f"--prefix={install_prefix}"
    if enable_readline:
        configure_args += " --enable-readline"
    
    print("Configuring MacPorts...")
    shell.exec(
        f"cd {source_dir} && ./configure {configure_args}",
        allowed_commands=["configure"]
    )
    
    # Build and install
    print("Building MacPorts...")
    shell.exec(f"cd {source_dir} && make", allowed_commands=["make"])
    
    print("Installing MacPorts...")
    shell.exec(f"cd {source_dir} && sudo make install", allowed_commands=["make"])
    
    # Cleanup
    fs.remove(temp_dir)

def _get_macos_version():
    """Get macOS version for installer selection."""
    setting_version = env.get("LORE_SETTING_MACOS_VERSION", "auto")
    if setting_version != "auto":
        return setting_version
    
    return platform.version

def _get_pkg_for_version(version):
    """Get appropriate .pkg filename for macOS version."""
    # Handle both "15.1" and "15" format versions
    major_version = version.split('.')[0]
    if len(version.split('.')) > 1:
        minor_version = version.split('.')[1]
        full_version = f"{major_version}.{minor_version}"
        if full_version in PKG_INSTALLERS:
            return PKG_INSTALLERS[full_version]
    
    return PKG_INSTALLERS.get(major_version)

def rollback():
    """Remove MacPorts installation."""
    if fs.exists("/opt/local/bin/port"):
        # Use the uninstall script if available
        if fs.exists("/opt/local/etc/macports/uninstall.sh"):
            shell.exec(
                "sudo /opt/local/etc/macports/uninstall.sh",
                allowed_commands=["uninstall.sh"]
            )
        else:
            # Manual removal
            shell.exec("sudo rm -rf /opt/local", allowed_commands=["rm"])
            shell.exec("sudo rm -rf /Applications/MacPorts", allowed_commands=["rm"])
