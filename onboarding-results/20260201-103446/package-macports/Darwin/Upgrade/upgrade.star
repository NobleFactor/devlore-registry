# macports/Darwin/Upgrade/upgrade.star

def upgrade(package, system, plan):
    """Upgrade MacPorts to new version."""
    
    # Use the same installation logic as Deploy
    if package.has_feature("install-from-git"):
        return _upgrade_from_git(package, system, plan)
    elif package.has_feature("install-from-source"):
        return _upgrade_from_source(package, system, plan)
    else:
        return _upgrade_from_pkg(package, system, plan)

def _upgrade_from_pkg(package, system, plan):
    """Upgrade using .pkg installer."""
    
    # Determine installer URL (same logic as install)
    macos_version = package.setting("macos-version", "auto")
    if macos_version == "auto":
        os_version = system.platform.version
        os_major = os_version.split(".")[0]
    else:
        os_major = macos_version
    
    PKG_SUFFIXES = {
        "26": "26-Tahoe",
        "15": "15-Sequoia",
        "14": "14-Sonoma", 
        "13": "13-Ventura",
        "12": "12-Monterey",
        "11": "11-BigSur",
    }
    
    suffix = PKG_SUFFIXES.get(os_major, "15-Sequoia")
    pkg_url = f"https://github.com/macports/macports-base/releases/download/v{package.version}/MacPorts-{package.version}-{suffix}.pkg"
    
    # Download and install new version
    download = plan.shell(f"curl -L -o /tmp/macports-upgrade.pkg {pkg_url}")
    install_pkg = plan.shell("sudo installer -pkg /tmp/macports-upgrade.pkg -target /")
    cleanup = plan.shell("rm -f /tmp/macports-upgrade.pkg")
    
    plan.depends_on(install_pkg, download)
    plan.depends_on(cleanup, install_pkg)
    
    return {"upgrade": True}

def _upgrade_from_source(package, system, plan):
    """Upgrade from source."""
    
    prefix = package.setting("prefix", "/opt/local")
    configure_args = package.setting("configure-args", "")
    
    tarball_url = f"https://distfiles.macports.org/MacPorts/MacPorts-{package.version}.tar.bz2"
    
    download = plan.shell(f"curl -L -o /tmp/macports-upgrade.tar.bz2 {tarball_url}")
    extract = plan.shell("cd /tmp && tar -xjf macports-upgrade.tar.bz2")
    configure = plan.shell(f"cd /tmp/MacPorts-{package.version} && ./configure --prefix={prefix} {configure_args}")
    make = plan.shell(f"cd /tmp/MacPorts-{package.version} && make")
    install = plan.shell(f"cd /tmp/MacPorts-{package.version} && sudo make install")
    cleanup = plan.shell(f"rm -rf /tmp/MacPorts-{package.version} /tmp/macports-upgrade.tar.bz2")
    
    plan.depends_on(extract, download)
    plan.depends_on(configure, extract)
    plan.depends_on(make, configure)
    plan.depends_on(install, make)
    plan.depends_on(cleanup, install)
    
    return {"upgrade": True}

def _upgrade_from_git(package, system, plan):
    """Upgrade from Git HEAD."""
    
    prefix = package.setting("prefix", "/opt/local")
    configure_args = package.setting("configure-args", "")
    
    clone = plan.shell("git clone https://github.com/macports/macports-base.git /tmp/macports-upgrade-git")
    autoreconf = plan.shell("cd /tmp/macports-upgrade-git && autoreconf -fvi")
    configure = plan.shell(f"cd /tmp/macports-upgrade-git && ./configure --prefix={prefix} {configure_args}")
    make = plan.shell("cd /tmp/macports-upgrade-git && make")
    install = plan.shell("cd /tmp/macports-upgrade-git && sudo make install")
    cleanup = plan.shell("rm -rf /tmp/macports-upgrade-git")
    
    plan.depends_on(autoreconf, clone)
    plan.depends_on(configure, autoreconf)
    plan.depends_on(make, configure)
    plan.depends_on(install, make)
    plan.depends_on(cleanup, install)
    
    return {"upgrade": True}

def rollback(package, system, plan):
    """Restore previous MacPorts installation."""
    # Restore configuration backup
    plan.shell("sudo rm -rf /opt/local/etc/macports")
    plan.shell("sudo mv /tmp/macports-config-backup /opt/local/etc/macports")
    return {"rollback": True}

