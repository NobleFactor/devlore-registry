# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# gcloud/prepare.star - Prepare phase for Google Cloud CLI installation
#
# Reference: https://cloud.google.com/sdk/docs/install

def prepare():
    """Prepare the system for Google Cloud CLI installation."""

    # Check for Python (required)
    if not shell.which("python3") and not shell.which("python"):
        fail("Python 3 is required for Google Cloud CLI")

    if platform.os == "darwin":
        _prepare_darwin()
    elif platform.os == "linux":
        _prepare_linux()
    elif platform.os == "windows":
        _prepare_windows()
    else:
        fail("Unsupported platform: " + platform.os)

def _prepare_darwin():
    """Prepare macOS for gcloud installation."""

    # Homebrew is available but Google recommends the installer
    if shell.which("brew"):
        log.info("Homebrew available; will use google-cloud-sdk cask")
    else:
        log.info("Will use Google Cloud SDK installer")

def _prepare_linux():
    """Prepare Linux for gcloud installation."""

    if platform.distro in ["debian", "ubuntu"]:
        _prepare_debian()
    elif platform.distro in ["fedora", "rhel", "centos"]:
        _prepare_rpm()
    else:
        # Direct installation
        package.install("curl")

def _prepare_debian():
    """Prepare Debian/Ubuntu for gcloud installation."""

    # Install prerequisites
    package.install("apt-transport-https")
    package.install("ca-certificates")
    package.install("gnupg")
    package.install("curl")

    # Add Google Cloud GPG key
    keyring_path = "/usr/share/keyrings/cloud.google.gpg"

    if not fs.exists(keyring_path):
        result = shell.run(
            "curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | " +
            "sudo gpg --dearmor -o " + keyring_path,
            shell = True,
        )
        if result.returncode != 0:
            fail("Failed to add Google Cloud GPG key: " + result.stderr)

    # Add repository
    sources_list = "/etc/apt/sources.list.d/google-cloud-sdk.list"

    if not fs.exists(sources_list):
        repo_line = "deb [signed-by=" + keyring_path + "] https://packages.cloud.google.com/apt cloud-sdk main"

        result = shell.run(
            "echo '" + repo_line + "' | sudo tee " + sources_list,
            shell = True,
        )
        if result.returncode != 0:
            fail("Failed to add Google Cloud SDK repository: " + result.stderr)

    # Update package lists
    package.update()

def _prepare_rpm():
    """Prepare Fedora/RHEL for gcloud installation."""

    # Add Google Cloud SDK repository
    repo_file = "/etc/yum.repos.d/google-cloud-sdk.repo"

    if not fs.exists(repo_file):
        repo_content = """[google-cloud-cli]
name=Google Cloud CLI
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el9-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
"""
        fs.write(repo_file, repo_content, sudo = True)

def _prepare_windows():
    """Prepare Windows for gcloud installation."""
    # Installer handles everything
    pass

def rollback():
    """Rollback preparation changes on failure."""

    if platform.os == "linux":
        if platform.distro in ["debian", "ubuntu"]:
            sources_list = "/etc/apt/sources.list.d/google-cloud-sdk.list"
            keyring_path = "/usr/share/keyrings/cloud.google.gpg"

            if fs.exists(sources_list):
                fs.remove(sources_list, sudo = True)
            if fs.exists(keyring_path):
                fs.remove(keyring_path, sudo = True)

            package.update()

        elif platform.distro in ["fedora", "rhel", "centos"]:
            repo_file = "/etc/yum.repos.d/google-cloud-sdk.repo"
            if fs.exists(repo_file):
                fs.remove(repo_file, sudo = True)
