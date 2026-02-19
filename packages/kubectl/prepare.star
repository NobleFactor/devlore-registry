# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# kubectl/prepare.star - Prepare phase for kubectl installation
#
# Reference: https://kubernetes.io/docs/tasks/tools/

def prepare():
    """Prepare the system for kubectl installation."""

    if platform.os == "darwin":
        _prepare_darwin()
    elif platform.os == "linux":
        _prepare_linux()
    elif platform.os == "windows":
        _prepare_windows()
    else:
        fail("Unsupported platform: " + platform.os)

def _prepare_darwin():
    """Prepare macOS for kubectl installation."""
    # Homebrew is preferred
    if not shell.which("brew"):
        log.info("Homebrew not found; will use direct download")

def _prepare_linux():
    """Prepare Linux for kubectl installation."""

    # Install prerequisites
    if platform.distro in ["debian", "ubuntu"]:
        package.install("curl")
        package.install("apt-transport-https")
        package.install("ca-certificates")

        # Add Kubernetes apt repository
        _add_kubernetes_apt_repo()

    elif platform.distro in ["fedora", "rhel", "centos"]:
        package.install("curl")

        # Add Kubernetes yum repository
        _add_kubernetes_yum_repo()

    else:
        # Other distributions: use direct download
        if not shell.which("curl"):
            fail("curl is required but not found")

def _add_kubernetes_apt_repo():
    """Add Kubernetes apt repository for Debian/Ubuntu."""

    keyring_dir = "/etc/apt/keyrings"
    keyring_path = keyring_dir + "/kubernetes-apt-keyring.gpg"
    sources_list = "/etc/apt/sources.list.d/kubernetes.list"

    # Create keyring directory if needed
    if not fs.exists(keyring_dir):
        shell.run("sudo mkdir -p " + keyring_dir)
        shell.run("sudo chmod 755 " + keyring_dir)

    # Download and add GPG key
    if not fs.exists(keyring_path):
        result = shell.run(
            "curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | " +
            "sudo gpg --dearmor -o " + keyring_path,
            shell = True,
        )
        if result.returncode != 0:
            fail("Failed to add Kubernetes GPG key: " + result.stderr)

    # Add repository
    if not fs.exists(sources_list):
        repo_line = "deb [signed-by=" + keyring_path + "] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /"
        result = shell.run(
            "echo '" + repo_line + "' | sudo tee " + sources_list,
            shell = True,
        )
        if result.returncode != 0:
            fail("Failed to add Kubernetes repository: " + result.stderr)

    # Update package lists
    package.update()

def _add_kubernetes_yum_repo():
    """Add Kubernetes yum repository for Fedora/RHEL."""

    repo_file = "/etc/yum.repos.d/kubernetes.repo"

    if not fs.exists(repo_file):
        repo_content = """[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/repodata/repomd.xml.key
"""
        fs.write(repo_file, repo_content, sudo = True)

def _prepare_windows():
    """Prepare Windows for kubectl installation."""
    # winget or chocolatey handles everything
    pass

