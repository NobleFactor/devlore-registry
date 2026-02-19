# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# azure-cli/install.star - Install phase for Azure CLI
#
# This phase performs the actual installation.

def install():
    """Install Azure CLI using the platform's package manager."""

    if platform.os == "darwin":
        _install_darwin()
    elif platform.os == "linux":
        _install_linux()
    elif platform.os == "windows":
        _install_windows()
    else:
        fail("Unsupported platform: " + platform.os)

def _install_darwin():
    """Install Azure CLI on macOS using Homebrew."""
    package.install("azure-cli", manager = "brew")

def _install_linux():
    """Install Azure CLI on Linux."""

    if platform.distro in ["debian", "ubuntu"]:
        # Repository was added in prepare phase
        package.install("azure-cli", manager = "apt")

    elif platform.distro in ["fedora", "rhel", "centos"]:
        # Repository was added in prepare phase
        package.install("azure-cli", manager = "dnf")

    else:
        # Fallback: use the Microsoft install script
        # This is less preferred but works on more distributions
        result = shell.run(
            "curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash",
            shell = True,
        )
        if result.returncode != 0:
            fail("Azure CLI installation failed: " + result.stderr)

def _install_windows():
    """Install Azure CLI on Windows using winget."""
    package.install("Microsoft.AzureCLI", manager = "winget")
