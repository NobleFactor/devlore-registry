# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# kubectl/verify.star - Verify phase for kubectl

def verify():
    """Verify kubectl installation is working."""

    # Check that kubectl command exists
    kubectl_path = shell.which("kubectl")
    if not kubectl_path:
        fail("kubectl command not found in PATH")

    # Check version output
    result = shell.run("kubectl version --client --output=yaml")
    if result.returncode != 0:
        fail("'kubectl version --client' failed: " + result.stderr)

    # Parse version
    version = _parse_version(result.stdout)
    if not version:
        fail("Could not parse kubectl version from output")

    log.info("kubectl version " + version + " is installed")

    # Verify completions if enabled
    if package.feature("completions"):
        _verify_completions()

    # Verify krew if enabled
    if package.feature("krew"):
        _verify_krew()

    # Verify auth plugins if enabled
    if package.feature("kubelogin"):
        _verify_kubelogin()

    if package.feature("aws-iam-authenticator"):
        _verify_aws_iam_authenticator()

    # Return success info for receipt
    return {
        "version": version,
        "path": kubectl_path,
        "completions": package.feature("completions"),
        "krew": package.feature("krew") and shell.which("kubectl-krew") != None,
        "kubelogin": package.feature("kubelogin") and shell.which("kubelogin") != None,
        "aws_iam_authenticator": package.feature("aws-iam-authenticator") and shell.which("aws-iam-authenticator") != None,
    }

def _parse_version(output):
    """Parse version string from kubectl version output."""
    # YAML output includes clientVersion.gitVersion
    for line in output.split("\n"):
        if "gitVersion:" in line:
            parts = line.split(":")
            if len(parts) >= 2:
                return parts[1].strip()
    return None

def _verify_completions():
    """Verify shell completions are installed."""

    user_shell = env.get("SHELL", "/bin/bash")

    if "bash" in user_shell:
        completions_file = fs.home() + "/.local/share/bash-completion/completions/kubectl"
    elif "zsh" in user_shell:
        completions_file = fs.home() + "/.local/share/zsh/site-functions/_kubectl"
    elif "fish" in user_shell:
        completions_file = fs.home() + "/.config/fish/completions/kubectl.fish"
    else:
        return

    if not fs.exists(completions_file):
        log.warn("Shell completions file not found: " + completions_file)
    else:
        log.info("Shell completions installed: " + completions_file)

def _verify_krew():
    """Verify krew is installed."""

    if shell.which("kubectl-krew"):
        result = shell.run("kubectl krew version")
        if result.returncode == 0:
            log.info("krew is installed")
        else:
            log.warn("krew found but version check failed")
    else:
        krew_path = fs.home() + "/.krew/bin/kubectl-krew"
        if fs.exists(krew_path):
            log.info("krew is installed at " + krew_path)
            log.warn("Ensure " + fs.home() + "/.krew/bin is in your PATH")
        else:
            log.warn("krew was requested but not found")

def _verify_kubelogin():
    """Verify kubelogin is installed."""

    if shell.which("kubelogin"):
        result = shell.run("kubelogin --version")
        if result.returncode == 0:
            log.info("kubelogin is installed: " + result.stdout.strip())
        else:
            log.warn("kubelogin found but version check failed")
    else:
        log.warn("kubelogin was requested but not found")

def _verify_aws_iam_authenticator():
    """Verify aws-iam-authenticator is installed."""

    if shell.which("aws-iam-authenticator"):
        result = shell.run("aws-iam-authenticator version")
        if result.returncode == 0:
            log.info("aws-iam-authenticator is installed")
        else:
            log.warn("aws-iam-authenticator found but version check failed")
    else:
        log.warn("aws-iam-authenticator was requested but not found")
