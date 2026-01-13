# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# aws-cli/install.star - Install phase for AWS CLI v2
#
# Reference: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

def install():
    """Install AWS CLI v2 using the appropriate method for the platform."""

    if platform.os == "darwin":
        _install_darwin()
    elif platform.os == "linux":
        _install_linux()
    elif platform.os == "windows":
        _install_windows()
    else:
        fail("Unsupported platform: " + platform.os)

def _install_darwin():
    """Install AWS CLI on macOS."""

    # Prefer Homebrew if available
    if shell.which("brew"):
        # Remove v1 if present
        result = shell.run("brew list awscli 2>/dev/null", shell = True)
        if result.returncode == 0:
            shell.run("brew uninstall awscli")

        package.install("awscli", manager = "brew")
    else:
        # Use the official pkg installer
        _install_darwin_pkg()

def _install_darwin_pkg():
    """Install AWS CLI on macOS using the pkg installer."""

    # Download the installer
    pkg_url = "https://awscli.amazonaws.com/AWSCLIV2.pkg"
    pkg_path = "/tmp/AWSCLIV2.pkg"

    result = shell.run("curl -o " + pkg_path + " " + pkg_url)
    if result.returncode != 0:
        fail("Failed to download AWS CLI installer: " + result.stderr)

    # Install the package
    result = shell.run("sudo installer -pkg " + pkg_path + " -target /")
    if result.returncode != 0:
        fail("Failed to install AWS CLI: " + result.stderr)

    # Clean up
    fs.remove(pkg_path)

def _install_linux():
    """Install AWS CLI on Linux using the bundled installer."""

    # Determine architecture
    arch = platform.arch
    if arch == "amd64":
        arch_suffix = "x86_64"
    elif arch == "arm64":
        arch_suffix = "aarch64"
    else:
        fail("Unsupported architecture: " + arch)

    # Download and extract
    zip_url = "https://awscli.amazonaws.com/awscli-exe-linux-" + arch_suffix + ".zip"
    zip_path = "/tmp/awscliv2.zip"
    extract_dir = "/tmp/aws"

    # Clean up any previous attempt
    if fs.exists(extract_dir):
        fs.remove(extract_dir, recursive = True)

    # Download
    result = shell.run("curl -o " + zip_path + " " + zip_url)
    if result.returncode != 0:
        fail("Failed to download AWS CLI: " + result.stderr)

    # Extract
    result = shell.run("unzip -q " + zip_path + " -d /tmp")
    if result.returncode != 0:
        fail("Failed to extract AWS CLI: " + result.stderr)

    # Check if updating or fresh install
    if shell.which("aws"):
        # Update existing installation
        result = shell.run("sudo " + extract_dir + "/install --update")
    else:
        # Fresh install
        result = shell.run("sudo " + extract_dir + "/install")

    if result.returncode != 0:
        fail("AWS CLI installation failed: " + result.stderr)

    # Clean up
    fs.remove(zip_path)
    fs.remove(extract_dir, recursive = True)

def _install_windows():
    """Install AWS CLI on Windows using winget."""

    # Check for winget
    if shell.which("winget"):
        package.install("Amazon.AWSCLI", manager = "winget")
    else:
        # Fall back to MSI installer
        _install_windows_msi()

def _install_windows_msi():
    """Install AWS CLI on Windows using the MSI installer."""

    msi_url = "https://awscli.amazonaws.com/AWSCLIV2.msi"
    msi_path = env.get("TEMP", "C:\\Temp") + "\\AWSCLIV2.msi"

    # Download
    result = shell.run('curl -o "' + msi_path + '" ' + msi_url)
    if result.returncode != 0:
        fail("Failed to download AWS CLI installer: " + result.stderr)

    # Install silently
    result = shell.run('msiexec /i "' + msi_path + '" /quiet')
    if result.returncode != 0:
        fail("AWS CLI installation failed: " + result.stderr)

    # Clean up
    fs.remove(msi_path)

def rollback():
    """Rollback installation on failure."""

    if platform.os == "darwin":
        if shell.which("brew"):
            shell.run("brew uninstall awscli 2>/dev/null", shell = True)
        else:
            # pkg installations are harder to remove
            log.warn("Manual removal may be required: rm -rf /usr/local/aws-cli")

    elif platform.os == "linux":
        # Remove the installation
        if fs.exists("/usr/local/aws-cli"):
            shell.run("sudo rm -rf /usr/local/aws-cli")
        if fs.exists("/usr/local/bin/aws"):
            shell.run("sudo rm /usr/local/bin/aws")
        if fs.exists("/usr/local/bin/aws_completer"):
            shell.run("sudo rm /usr/local/bin/aws_completer")

    elif platform.os == "windows":
        if shell.which("winget"):
            shell.run("winget uninstall Amazon.AWSCLI")
