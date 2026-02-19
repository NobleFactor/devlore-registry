# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# kubectl/provision.star - Provision phase for kubectl
#
# This phase configures kubectl and installs optional components.

def provision():
    """Configure kubectl after installation."""

    # Install shell completions if enabled
    if package.feature("completions"):
        _install_completions()

    # Install krew plugin manager if enabled
    if package.feature("krew"):
        _install_krew()

    # Install cloud-specific auth plugins
    if package.feature("kubelogin"):
        _install_kubelogin()

    if package.feature("aws-iam-authenticator"):
        _install_aws_iam_authenticator()

def _install_completions():
    """Install shell completions for kubectl."""

    user_shell = env.get("SHELL", "/bin/bash")

    if "bash" in user_shell:
        _install_bash_completions()
    elif "zsh" in user_shell:
        _install_zsh_completions()
    elif "fish" in user_shell:
        _install_fish_completions()

def _install_bash_completions():
    """Install bash completions for kubectl."""

    completions_dir = fs.home() + "/.local/share/bash-completion/completions"
    fs.mkdir(completions_dir, parents = True)

    completions_file = completions_dir + "/kubectl"

    result = shell.run("kubectl completion bash")
    if result.returncode == 0:
        fs.write(completions_file, result.stdout)
        log.info("Installed bash completions to " + completions_file)
    else:
        log.warn("Failed to generate bash completions: " + result.stderr)

def _install_zsh_completions():
    """Install zsh completions for kubectl."""

    completions_dir = fs.home() + "/.local/share/zsh/site-functions"
    fs.mkdir(completions_dir, parents = True)

    completions_file = completions_dir + "/_kubectl"

    result = shell.run("kubectl completion zsh")
    if result.returncode == 0:
        fs.write(completions_file, result.stdout)
        log.info("Installed zsh completions to " + completions_file)
    else:
        log.warn("Failed to generate zsh completions: " + result.stderr)

def _install_fish_completions():
    """Install fish completions for kubectl."""

    completions_dir = fs.home() + "/.config/fish/completions"
    fs.mkdir(completions_dir, parents = True)

    completions_file = completions_dir + "/kubectl.fish"

    result = shell.run("kubectl completion fish")
    if result.returncode == 0:
        fs.write(completions_file, result.stdout)
        log.info("Installed fish completions to " + completions_file)
    else:
        log.warn("Failed to generate fish completions: " + result.stderr)

def _install_krew():
    """Install krew kubectl plugin manager."""
    # Reference: https://krew.sigs.k8s.io/docs/user-guide/setup/install/

    if shell.which("kubectl-krew") or shell.which("krew"):
        log.info("krew is already installed")
        return

    if platform.os == "darwin" and shell.which("brew"):
        result = shell.run("brew install krew")
        if result.returncode == 0:
            log.info("Installed krew via Homebrew")
            return

    # Install via script
    krew_root = fs.home() + "/.krew"
    krew_bin = krew_root + "/bin"

    # Determine OS and arch
    os_name = platform.os
    if os_name == "darwin":
        os_name = "darwin"
    else:
        os_name = "linux"

    arch = platform.arch
    if arch == "amd64":
        arch = "amd64"
    elif arch == "arm64":
        arch = "arm64"

    krew_archive = "krew-" + os_name + "_" + arch + ".tar.gz"
    krew_url = "https://github.com/kubernetes-sigs/krew/releases/latest/download/" + krew_archive

    # Download and install
    result = shell.run(
        "cd /tmp && " +
        "curl -fsSLO " + krew_url + " && " +
        "tar zxf " + krew_archive + " && " +
        "./krew-" + os_name + "_" + arch + " install krew",
        shell = True,
    )

    if result.returncode == 0:
        log.info("Installed krew")
        log.info("Add " + krew_bin + " to your PATH")
    else:
        log.warn("Failed to install krew: " + result.stderr)

def _install_kubelogin():
    """Install Azure AD kubelogin for AKS authentication."""
    # Reference: https://github.com/Azure/kubelogin

    if shell.which("kubelogin"):
        log.info("kubelogin is already installed")
        return

    if platform.os == "darwin" and shell.which("brew"):
        result = shell.run("brew install Azure/kubelogin/kubelogin")
        if result.returncode == 0:
            log.info("Installed kubelogin via Homebrew")
            return

    # Install via az CLI extension if available
    if shell.which("az"):
        result = shell.run("az aks install-cli")
        if result.returncode == 0:
            log.info("Installed kubelogin via az aks install-cli")
            return

    # Direct download
    os_name = platform.os
    arch = platform.arch

    if os_name == "darwin":
        os_suffix = "darwin"
    elif os_name == "linux":
        os_suffix = "linux"
    elif os_name == "windows":
        os_suffix = "windows"
    else:
        log.warn("kubelogin not available for " + os_name)
        return

    if arch == "amd64":
        arch_suffix = "amd64"
    elif arch == "arm64":
        arch_suffix = "arm64"
    else:
        log.warn("kubelogin not available for architecture " + arch)
        return

    # Download latest release
    if os_name == "windows":
        archive_name = "kubelogin-" + os_suffix + "-" + arch_suffix + ".zip"
    else:
        archive_name = "kubelogin-" + os_suffix + "-" + arch_suffix + ".zip"

    download_url = "https://github.com/Azure/kubelogin/releases/latest/download/" + archive_name

    result = shell.run(
        "cd /tmp && " +
        "curl -fsSLO " + download_url + " && " +
        "unzip -o " + archive_name + " && " +
        "sudo mv bin/" + os_suffix + "_" + arch_suffix + "/kubelogin /usr/local/bin/",
        shell = True,
    )

    if result.returncode == 0:
        log.info("Installed kubelogin")
    else:
        log.warn("Failed to install kubelogin: " + result.stderr)

def _install_aws_iam_authenticator():
    """Install AWS IAM authenticator for EKS."""
    # Reference: https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html

    if shell.which("aws-iam-authenticator"):
        log.info("aws-iam-authenticator is already installed")
        return

    if platform.os == "darwin" and shell.which("brew"):
        result = shell.run("brew install aws-iam-authenticator")
        if result.returncode == 0:
            log.info("Installed aws-iam-authenticator via Homebrew")
            return

    # Direct download
    os_name = platform.os
    if os_name == "darwin":
        os_suffix = "darwin"
    elif os_name == "linux":
        os_suffix = "linux"
    else:
        log.warn("aws-iam-authenticator not supported on " + os_name + " via direct download")
        return

    arch = platform.arch
    if arch == "amd64":
        arch_suffix = "amd64"
    elif arch == "arm64":
        arch_suffix = "arm64"
    else:
        log.warn("aws-iam-authenticator not available for architecture " + arch)
        return

    download_url = "https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/latest/download/aws-iam-authenticator_" + os_suffix + "_" + arch_suffix

    result = shell.run(
        "curl -Lo /tmp/aws-iam-authenticator " + download_url + " && " +
        "sudo install -o root -g root -m 0755 /tmp/aws-iam-authenticator /usr/local/bin/aws-iam-authenticator",
        shell = True,
    )

    if result.returncode == 0:
        log.info("Installed aws-iam-authenticator")
    else:
        log.warn("Failed to install aws-iam-authenticator: " + result.stderr)

