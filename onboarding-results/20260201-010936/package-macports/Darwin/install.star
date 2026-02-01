# macports/Darwin/install.star - Install phase for MacPorts on macOS
#
# TRIBAL KNOWLEDGE:
# MacPorts provides version-specific .pkg installers for each macOS release.
# Using the wrong version causes build failures due to incompatible system libraries.

# macOS version to installer mapping
INSTALLER_MAP = {
    "15": "https://github.com/macports/macports-base/releases/download/v2.11.6/MacPorts-2.11.6-15-Sequoia.pkg",
    "14": "https://github.com/macports/macports-base/releases/download/v2.11.6/MacPorts-2.11.6-14-Sonoma.pkg",
    "13": "https://github.com/macports/macports-base/releases/download/v2.11.6/MacPorts-2.11.6-13-Ventura.pkg",
    "12": "https://github.com/macports/macports-base/releases/download/v2.11.6/MacPorts-2.11.6-12-Monterey.pkg",
    "11": "https://github.com/macports/macports-base/releases/download/v2.11.6/MacPorts-2.11.6-11-BigSur.pkg",
}

def install():
    """Install MacPorts using the appropriate method."""
    if _should_use_pkg_installer():
        _install_via_pkg()
    else:
        _install_from_source()
    
    # TRIBAL KNOWLEDGE: Always selfupdate after installation
    # This ensures the ports tree is current and prevents stale port definitions
    _initial_selfupdate()
    return {"install": True}

def _should_use_pkg_installer():
    """Determine if we should use pkg installer vs source."""
    major_version = platform.version.split(".")[0]
    return major_version in INSTALLER_MAP

def _install_via_pkg():
    """Install using version-specific .pkg installer."""
    major_version = platform.version.split(".")[0]
    pkg_url = INSTALLER_MAP[major_version]
    
    # TRIBAL KNOWLEDGE: Each macOS version needs its specific installer
    # This ensures compatibility with system libraries and compilers
    temp_pkg = "/tmp/MacPorts.pkg"
    http.download(pkg_url, temp_pkg)
    
    shell.exec(
        f"sudo installer -pkg {temp_pkg} -target /",
        allowed_commands=["installer"],
    )
    
    fs.remove(temp_pkg)

def _install_from_source():
    """Install from source for unsupported macOS versions."""
    version = "2.11.6"
    tarball_url = f"https://distfiles.macports.org/MacPorts/MacPorts-{version}.tar.gz"
    temp_dir = f"/tmp/MacPorts-{version}"
    tarball = f"{temp_dir}.tar.gz"
    
    # Download and extract
    http.download(tarball_url, tarball)
    archive.extract(tarball, "/tmp")
    
    # Build and install
    shell.exec(
        f"cd {temp_dir} && ./configure --prefix=/opt/local",
        allowed_commands=["configure"],
    )
    shell.exec(
        f"cd {temp_dir} && make",
        allowed_commands=["make"],
    )
    shell.exec(
        f"cd {temp_dir} && sudo make install",
        allowed_commands=["make"],
    )
    
    # Cleanup
    fs.remove(temp_dir)
    fs.remove(tarball)

def _initial_selfupdate():
    """Run initial selfupdate to sync ports tree."""
    # TRIBAL KNOWLEDGE: Migration support available in 2.10.0+
    # For OS upgrades, 'sudo port migrate' is preferred over reinstall
    shell.exec(
        "sudo /opt/local/bin/port -v selfupdate",
        allowed_commands=["port"],
    )

def rollback():
    """Remove MacPorts installation."""
    # TRIBAL KNOWLEDGE: MacPorts doesn't provide an uninstaller
    # Manual removal requires deleting multiple directories
    directories_to_remove = [
        "/opt/local",
        "/Library/LaunchDaemons/org.macports.*",
        "/Library/Receipts/MacPorts*.pkg",
        "/Library/Receipts/DarwinPorts*.pkg",
    ]
    
    for path in directories_to_remove:
        if fs.exists(path):
            shell.exec(
                f"sudo rm -rf {path}",
                allowed_commands=["rm"],
            )

