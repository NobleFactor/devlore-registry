# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# terraform/prepare.star - Prepare phase for Terraform installation
#
# Reference: https://developer.hashicorp.com/terraform/install

def prepare():
    """Prepare the system for Terraform installation."""

    if platform.os == "darwin":
        _prepare_darwin()
    elif platform.os == "linux":
        _prepare_linux()
    elif platform.os == "windows":
        _prepare_windows()
    else:
        fail("Unsupported platform: " + platform.os)

def _prepare_darwin():
    """Prepare macOS for Terraform installation."""

    # Homebrew is the preferred method
    if shell.which("brew"):
        # Add HashiCorp tap
        result = shell.run("brew tap hashicorp/tap")
        if result.returncode != 0:
            log.warn("Failed to add HashiCorp tap: " + result.stderr)
    else:
        log.info("Homebrew not found; will use direct download")

def _prepare_linux():
    """Prepare Linux for Terraform installation."""

    if platform.distro in ["debian", "ubuntu"]:
        _prepare_debian()
    elif platform.distro in ["fedora", "rhel", "centos"]:
        _prepare_rpm()
    else:
        # Direct download will be used
        if not shell.which("curl"):
            fail("curl is required but not found")
        if not shell.which("unzip"):
            fail("unzip is required but not found")

def _prepare_debian():
    """Prepare Debian/Ubuntu for Terraform installation."""

    # Install prerequisites
    package.install("gnupg")
    package.install("software-properties-common")
    package.install("curl")

    # Add HashiCorp GPG key
    keyring_path = "/usr/share/keyrings/hashicorp-archive-keyring.gpg"

    if not fs.exists(keyring_path):
        result = shell.run(
            "curl -fsSL https://apt.releases.hashicorp.com/gpg | " +
            "sudo gpg --dearmor -o " + keyring_path,
            shell = True,
        )
        if result.returncode != 0:
            fail("Failed to add HashiCorp GPG key: " + result.stderr)

    # Add repository
    sources_list = "/etc/apt/sources.list.d/hashicorp.list"

    if not fs.exists(sources_list):
        arch = shell.output("dpkg --print-architecture").strip()
        codename = shell.output("lsb_release -cs").strip()

        repo_line = "deb [arch=" + arch + " signed-by=" + keyring_path + "] https://apt.releases.hashicorp.com " + codename + " main"

        result = shell.run(
            "echo '" + repo_line + "' | sudo tee " + sources_list,
            shell = True,
        )
        if result.returncode != 0:
            fail("Failed to add HashiCorp repository: " + result.stderr)

    # Update package lists
    package.update()

def _prepare_rpm():
    """Prepare Fedora/RHEL for Terraform installation."""

    # Add HashiCorp repository
    result = shell.run("sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo")
    if result.returncode != 0:
        # Try dnf variant
        result = shell.run("sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo")
        if result.returncode != 0:
            log.warn("Failed to add HashiCorp repository; will use direct download")

def _prepare_windows():
    """Prepare Windows for Terraform installation."""
    # winget or chocolatey handles everything
    pass

