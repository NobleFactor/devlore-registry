# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# azure-cli/prepare.star - Prepare phase for Azure CLI installation
#
# This phase ensures prerequisites are met before installation.

def prepare():
    """Prepare the system for Azure CLI installation."""

    # Platform-specific preparation
    if platform.os == "darwin":
        _prepare_darwin()
    elif platform.os == "linux":
        _prepare_linux()
    elif platform.os == "windows":
        _prepare_windows()
    else:
        fail("Unsupported platform: " + platform.os)

def _prepare_darwin():
    """Prepare macOS for Azure CLI installation."""
    # Homebrew handles dependencies
    if not shell.which("brew"):
        fail("Homebrew is required on macOS. Install from https://brew.sh")

def _prepare_linux():
    """Prepare Linux for Azure CLI installation."""

    if platform.distro in ["debian", "ubuntu"]:
        _prepare_debian()
    elif platform.distro in ["fedora", "rhel", "centos"]:
        _prepare_rpm()
    else:
        fail("Unsupported Linux distribution: " + platform.distro)

def _prepare_debian():
    """Prepare Debian/Ubuntu for Azure CLI installation."""

    # Install prerequisites
    package.install("apt-transport-https")
    package.install("ca-certificates")
    package.install("curl")
    package.install("gnupg")
    package.install("lsb-release")

    # Add Microsoft GPG key
    # Reference: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux
    gpg_key_url = "https://packages.microsoft.com/keys/microsoft.asc"
    keyring_path = "/etc/apt/keyrings/microsoft.gpg"

    if not fs.exists(keyring_path):
        result = shell.run(
            "curl -sLS " + gpg_key_url + " | gpg --dearmor | sudo tee " + keyring_path + " > /dev/null",
            shell = True,
        )
        if result.returncode != 0:
            fail("Failed to add Microsoft GPG key: " + result.stderr)

        # Set permissions
        shell.run("sudo chmod go+r " + keyring_path)

    # Add Azure CLI repository
    sources_list = "/etc/apt/sources.list.d/azure-cli.list"
    if not fs.exists(sources_list):
        # Get architecture and distribution codename
        arch = shell.output("dpkg --print-architecture").strip()
        codename = shell.output("lsb_release -cs").strip()

        repo_line = "deb [arch=" + arch + " signed-by=" + keyring_path + "] https://packages.microsoft.com/repos/azure-cli/ " + codename + " main"

        result = shell.run(
            "echo '" + repo_line + "' | sudo tee " + sources_list,
            shell = True,
        )
        if result.returncode != 0:
            fail("Failed to add Azure CLI repository: " + result.stderr)

    # Update package lists
    package.update()

def _prepare_rpm():
    """Prepare Fedora/RHEL for Azure CLI installation."""

    # Import Microsoft GPG key
    result = shell.run("sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc")
    if result.returncode != 0:
        fail("Failed to import Microsoft GPG key: " + result.stderr)

    # Add Azure CLI repository
    repo_file = "/etc/yum.repos.d/azure-cli.repo"
    if not fs.exists(repo_file):
        repo_content = """[azure-cli]
name=Azure CLI
baseurl=https://packages.microsoft.com/yumrepos/azure-cli
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
"""
        fs.write(repo_file, repo_content, sudo = True)

def _prepare_windows():
    """Prepare Windows for Azure CLI installation."""
    # winget handles everything; no preparation needed
    pass

def rollback():
    """Rollback preparation changes on failure."""

    if platform.os == "linux":
        if platform.distro in ["debian", "ubuntu"]:
            # Remove repository and key if we added them
            sources_list = "/etc/apt/sources.list.d/azure-cli.list"
            keyring_path = "/etc/apt/keyrings/microsoft.gpg"

            if fs.exists(sources_list):
                fs.remove(sources_list, sudo = True)
            if fs.exists(keyring_path):
                fs.remove(keyring_path, sudo = True)

            package.update()

        elif platform.distro in ["fedora", "rhel", "centos"]:
            repo_file = "/etc/yum.repos.d/azure-cli.repo"
            if fs.exists(repo_file):
                fs.remove(repo_file, sudo = True)
