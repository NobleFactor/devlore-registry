# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# terraform/install.star - Install phase for Terraform

def install():
    """Install Terraform using the appropriate method for the platform."""

    if platform.os == "darwin":
        _install_darwin()
    elif platform.os == "linux":
        _install_linux()
    elif platform.os == "windows":
        _install_windows()
    else:
        fail("Unsupported platform: " + platform.os)

def _install_darwin():
    """Install Terraform on macOS."""

    if shell.which("brew"):
        # Use HashiCorp tap for latest version
        package.install("hashicorp/tap/terraform", manager = "brew")
    else:
        _install_direct()

def _install_linux():
    """Install Terraform on Linux."""

    if platform.distro in ["debian", "ubuntu"]:
        # Repository was added in prepare phase
        package.install("terraform", manager = "apt")

    elif platform.distro in ["fedora", "rhel", "centos"]:
        # Repository was added in prepare phase
        package.install("terraform", manager = "dnf")

    else:
        # Direct download for other distributions
        _install_direct()

def _install_windows():
    """Install Terraform on Windows."""

    if shell.which("winget"):
        package.install("Hashicorp.Terraform", manager = "winget")
    elif shell.which("choco"):
        package.install("terraform", manager = "choco")
    else:
        _install_direct()

def _install_direct():
    """Install Terraform via direct download."""

    # Get version to install
    version = package.setting("version", "")
    if not version:
        # Get latest version from releases API
        result = shell.run("curl -s https://api.github.com/repos/hashicorp/terraform/releases/latest | grep tag_name")
        if result.returncode == 0 and "tag_name" in result.stdout:
            # Parse version from: "tag_name": "v1.10.0",
            for part in result.stdout.split('"'):
                if part.startswith("v"):
                    version = part[1:]  # Remove 'v' prefix
                    break

    if not version:
        fail("Could not determine latest Terraform version")

    # Determine OS and architecture
    os_name = platform.os
    if os_name == "darwin":
        os_name = "darwin"
    elif os_name == "linux":
        os_name = "linux"
    elif os_name == "windows":
        os_name = "windows"

    arch = platform.arch
    if arch == "amd64":
        arch = "amd64"
    elif arch == "arm64":
        arch = "arm64"
    else:
        fail("Unsupported architecture: " + arch)

    # Download URL
    zip_name = "terraform_" + version + "_" + os_name + "_" + arch + ".zip"
    download_url = "https://releases.hashicorp.com/terraform/" + version + "/" + zip_name

    # Download and extract
    result = shell.run(
        "cd /tmp && " +
        "curl -fsSLO " + download_url + " && " +
        "unzip -o " + zip_name,
        shell = True,
    )
    if result.returncode != 0:
        fail("Failed to download Terraform: " + result.stderr)

    # Install
    if platform.os == "windows":
        install_dir = env.get("LOCALAPPDATA", "") + "\\terraform"
        fs.mkdir(install_dir, parents = True)
        fs.move("/tmp/terraform.exe", install_dir + "\\terraform.exe")
        log.info("Installed to " + install_dir + ". Add to PATH if needed.")
    else:
        shell.run("sudo install -o root -g root -m 0755 /tmp/terraform /usr/local/bin/terraform")

    # Clean up
    if platform.os != "windows":
        fs.remove("/tmp/" + zip_name)
        fs.remove("/tmp/terraform")

def rollback():
    """Rollback installation on failure."""

    if platform.os == "darwin":
        if shell.which("brew"):
            shell.run("brew uninstall hashicorp/tap/terraform 2>/dev/null", shell = True)

    elif platform.os == "linux":
        if platform.distro in ["debian", "ubuntu"]:
            package.remove("terraform", manager = "apt")
        elif platform.distro in ["fedora", "rhel", "centos"]:
            package.remove("terraform", manager = "dnf")
        else:
            if fs.exists("/usr/local/bin/terraform"):
                shell.run("sudo rm /usr/local/bin/terraform")

    elif platform.os == "windows":
        if shell.which("winget"):
            shell.run("winget uninstall Hashicorp.Terraform")
        elif shell.which("choco"):
            shell.run("choco uninstall terraform -y")
