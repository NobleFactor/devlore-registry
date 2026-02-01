# macports/Darwin/Upgrade/upgrade.star - Upgrade phase for MacPorts
#
# TRIBAL KNOWLEDGE:
# MacPorts upgrades are complex because they often coincide with OS upgrades.
# The base MacPorts system must be upgraded first, then ports may need to be
# migrated or rebuilt. Always use the version-specific installer for your OS.

def upgrade():
    """Upgrade MacPorts to newer version."""
    _upgrade_macports_base()
    _update_port_definitions()
    return {"upgrade": True}

def _upgrade_macports_base():
    """Upgrade the MacPorts base system."""
    install_from_source = env.get("LORE_FEATURE_INSTALL_FROM_SOURCE", "false") == "true"
    
    if install_from_source:
        _upgrade_from_source()
    else:
        _upgrade_from_pkg()

def _upgrade_from_pkg():
    """Upgrade using .pkg installer."""
    # Re-use installation logic with version-specific pkg
    macos_version = _get_macos_version()
    pkg_filename = _get_pkg_for_version(macos_version)
    
    if not pkg_filename:
        fail(f"No MacPorts .pkg installer available for macOS {macos_version}")
    
    pkg_url = f"https://distfiles.macports.org/MacPorts/{pkg_filename}"
    temp_path = f"/tmp/{pkg_filename}"
    
    print(f"Downloading MacPorts {macos_version} installer...")
    http.download(pkg_url, temp_path)
    
    print("Upgrading MacPorts base...")
    shell.exec(
        f"sudo installer -pkg {temp_path} -target /",
        allowed_commands=["installer"]
    )
    
    fs.remove(temp_path)

def _upgrade_from_source():
    """Upgrade from source."""
    enable_readline = env.get("LORE_FEATURE_ENABLE_READLINE", "true") == "true"
    install_prefix = env.get("LORE_SETTING_INSTALL_PREFIX", "/opt/local")
    
    temp_dir = "/tmp/macports-upgrade"
    tarball_path = f"{temp_dir}/MacPorts-2.11.6.tar.bz2"
    source_url = "https://distfiles.macports.org/MacPorts/MacPorts-2.11.6.tar.bz2"
    
    fs.mkdir(temp_dir)
    
    print("Downloading MacPorts source...")
    http.download(source_url, tarball_path)
    
    print("Extracting source...")
    archive.extract(tarball_path, temp_dir)
    
    source_dir = f"{temp_dir}/MacPorts-2.11.6"
    
    # Configure with same prefix as existing installation
    configure_args = f"--prefix={install_prefix}"
    if enable_readline:
        configure_args += " --enable-readline"
    
    print("Configuring MacPorts...")
    shell.exec(
        f"cd {source_dir} && ./configure {configure_args}",
        allowed_commands=["configure"]
    )
    
    print("Building MacPorts...")
    shell.exec(f"cd {source_dir} && make", allowed_commands=["make"])
    
    print("Installing MacPorts upgrade...")
    shell.exec(f"cd {source_dir} && sudo make install", allowed_commands=["make"])
    
    fs.remove(temp_dir)

def _update_port_definitions():
    """Update port definitions after base upgrade."""
    print("Updating port definitions...")
    result = shell.exec(
        "sudo port -v selfupdate",
        allowed_commands=["port"]
    )
    
    if not result.success:
        fail("Failed to update port definitions after upgrade")
    
    print("Port definitions updated successfully")

def _get_macos_version():
    """Get macOS version for installer selection."""
    setting_version = env.get("LORE_SETTING_MACOS_VERSION", "auto")
    if setting_version != "auto":
        return setting_version
    return platform.version

def _get_pkg_for_version(version):
    """Get appropriate .pkg filename for macOS version."""
    pkg_installers = {
        "26": "MacPorts-2.11.6-26-Tahoe.pkg",
        "15": "MacPorts-2.11.6-15-Sequoia.pkg", 
        "14": "MacPorts-2.11.6-14-Sonoma.pkg",
        "13": "MacPorts-2.11.6-13-Ventura.pkg",
        "12": "MacPorts-2.11.6-12-Monterey.pkg",
        "11": "MacPorts-2.11.6-11-BigSur.pkg"
    }
    
    major_version = version.split('.')[0]
    if len(version.split('.')) > 1:
        minor_version = version.split('.')[1]
        full_version = f"{major_version}.{minor_version}"
        if full_version in pkg_installers:
            return pkg_installers[full_version]
    
    return pkg_installers.get(major_version)

def rollback():
    """Rollback upgrade by restoring from backup."""
    print("MacPorts upgrade rollback is complex - manual intervention may be needed")
    print("Consider restoring from Time Machine backup if available")
