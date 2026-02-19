# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# kubectl/install.star - Install phase for kubectl

def install():
    """Install kubectl using the appropriate method for the platform."""

    if platform.os == "darwin":
        _install_darwin()
    elif platform.os == "linux":
        _install_linux()
    elif platform.os == "windows":
        _install_windows()
    else:
        fail("Unsupported platform: " + platform.os)

def _install_darwin():
    """Install kubectl on macOS."""

    if shell.which("brew"):
        package.install("kubectl", manager = "brew")
    else:
        _install_direct()

def _install_linux():
    """Install kubectl on Linux."""

    if platform.distro in ["debian", "ubuntu"]:
        # Repository was added in prepare phase
        package.install("kubectl", manager = "apt")

    elif platform.distro in ["fedora", "rhel", "centos"]:
        # Repository was added in prepare phase
        package.install("kubectl", manager = "dnf")

    else:
        # Direct download for other distributions
        _install_direct()

def _install_windows():
    """Install kubectl on Windows."""

    if shell.which("winget"):
        package.install("Kubernetes.kubectl", manager = "winget")
    elif shell.which("choco"):
        package.install("kubernetes-cli", manager = "choco")
    else:
        _install_direct()

def _install_direct():
    """Install kubectl via direct download."""

    # Determine the download URL
    version = package.setting("version", "")
    if not version:
        # Get latest stable version
        result = shell.run("curl -L -s https://dl.k8s.io/release/stable.txt")
        if result.returncode != 0:
            fail("Failed to get latest kubectl version: " + result.stderr)
        version = result.stdout.strip()

    # Ensure version starts with 'v'
    if not version.startswith("v"):
        version = "v" + version

    # Determine OS and architecture for download URL
    os_name = platform.os
    if os_name == "darwin":
        os_name = "darwin"
    elif os_name == "windows":
        os_name = "windows"
    else:
        os_name = "linux"

    arch = platform.arch
    if arch == "amd64":
        arch = "amd64"
    elif arch == "arm64":
        arch = "arm64"
    else:
        fail("Unsupported architecture: " + arch)

    # Build download URL
    if platform.os == "windows":
        binary_name = "kubectl.exe"
    else:
        binary_name = "kubectl"

    download_url = "https://dl.k8s.io/release/" + version + "/bin/" + os_name + "/" + arch + "/" + binary_name

    # Download
    if platform.os == "windows":
        install_path = env.get("LOCALAPPDATA", "") + "\\kubectl\\kubectl.exe"
        install_dir = env.get("LOCALAPPDATA", "") + "\\kubectl"
        fs.mkdir(install_dir, parents = True)
    else:
        install_path = "/usr/local/bin/kubectl"

    result = shell.run("curl -LO " + download_url)
    if result.returncode != 0:
        fail("Failed to download kubectl: " + result.stderr)

    # Install
    if platform.os == "windows":
        fs.move(binary_name, install_path)
    else:
        shell.run("sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl")
        fs.remove("kubectl")

