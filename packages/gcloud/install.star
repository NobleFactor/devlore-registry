# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# gcloud/install.star - Install phase for Google Cloud CLI

def install():
    """Install Google Cloud CLI using the appropriate method for the platform."""

    if platform.os == "darwin":
        _install_darwin()
    elif platform.os == "linux":
        _install_linux()
    elif platform.os == "windows":
        _install_windows()
    else:
        fail("Unsupported platform: " + platform.os)

def _install_darwin():
    """Install gcloud on macOS."""

    if shell.which("brew"):
        # Use Homebrew cask
        package.install("google-cloud-sdk", manager = "brew", cask = True)
    else:
        _install_interactive()

def _install_linux():
    """Install gcloud on Linux."""

    if platform.distro in ["debian", "ubuntu"]:
        # Repository was added in prepare phase
        package.install("google-cloud-cli", manager = "apt")

    elif platform.distro in ["fedora", "rhel", "centos"]:
        # Repository was added in prepare phase
        package.install("google-cloud-cli", manager = "dnf")

    else:
        # Use the interactive installer
        _install_interactive()

def _install_windows():
    """Install gcloud on Windows."""

    if shell.which("winget"):
        package.install("Google.CloudSDK", manager = "winget")
    elif shell.which("choco"):
        package.install("gcloudsdk", manager = "choco")
    else:
        # Download and run installer
        _install_windows_interactive()

def _install_interactive():
    """Install using the interactive installer script."""

    # Download the installer
    if platform.os == "darwin":
        if platform.arch == "arm64":
            archive_url = "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-darwin-arm.tar.gz"
        else:
            archive_url = "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-darwin-x86_64.tar.gz"
    else:
        if platform.arch == "arm64":
            archive_url = "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-arm.tar.gz"
        else:
            archive_url = "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz"

    install_dir = fs.home()
    archive_path = "/tmp/google-cloud-cli.tar.gz"

    # Download
    result = shell.run("curl -o " + archive_path + " " + archive_url)
    if result.returncode != 0:
        fail("Failed to download Google Cloud CLI: " + result.stderr)

    # Extract to home directory
    result = shell.run("tar -xzf " + archive_path + " -C " + install_dir)
    if result.returncode != 0:
        fail("Failed to extract Google Cloud CLI: " + result.stderr)

    # Run install script (non-interactive)
    sdk_dir = install_dir + "/google-cloud-sdk"
    result = shell.run(sdk_dir + "/install.sh --quiet --path-update=true")
    if result.returncode != 0:
        fail("Google Cloud CLI installation failed: " + result.stderr)

    # Clean up
    fs.remove(archive_path)

    log.info("Google Cloud CLI installed to " + sdk_dir)
    log.info("Restart your shell or run: source " + sdk_dir + "/path.bash.inc")

def _install_windows_interactive():
    """Install on Windows using the installer."""

    installer_url = "https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe"
    installer_path = env.get("TEMP", "C:\\Temp") + "\\GoogleCloudSDKInstaller.exe"

    # Download
    result = shell.run('curl -o "' + installer_path + '" ' + installer_url)
    if result.returncode != 0:
        fail("Failed to download Google Cloud SDK installer: " + result.stderr)

    # Run installer (silent mode)
    result = shell.run('"' + installer_path + '" /S')
    if result.returncode != 0:
        log.warn("Silent installation may have failed. Run installer manually: " + installer_path)

    # Clean up
    fs.remove(installer_path)

def rollback():
    """Rollback installation on failure."""

    if platform.os == "darwin":
        if shell.which("brew"):
            shell.run("brew uninstall --cask google-cloud-sdk 2>/dev/null", shell = True)
        else:
            sdk_dir = fs.home() + "/google-cloud-sdk"
            if fs.exists(sdk_dir):
                fs.remove(sdk_dir, recursive = True)

    elif platform.os == "linux":
        if platform.distro in ["debian", "ubuntu"]:
            package.remove("google-cloud-cli", manager = "apt")
        elif platform.distro in ["fedora", "rhel", "centos"]:
            package.remove("google-cloud-cli", manager = "dnf")
        else:
            sdk_dir = fs.home() + "/google-cloud-sdk"
            if fs.exists(sdk_dir):
                fs.remove(sdk_dir, recursive = True)

    elif platform.os == "windows":
        if shell.which("winget"):
            shell.run("winget uninstall Google.CloudSDK")
        elif shell.which("choco"):
            shell.run("choco uninstall gcloudsdk -y")
