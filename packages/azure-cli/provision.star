# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# azure-cli/provision.star - Provision phase for Azure CLI
#
# This phase configures the installed software.

def provision():
    """Configure Azure CLI after installation."""

    # Configure telemetry based on settings
    if not package.setting("telemetry", True):
        _disable_telemetry()

    # Install shell completions if enabled
    if package.feature("completions"):
        _install_completions()

    # Install extensions if enabled
    if package.feature("extensions"):
        _install_extensions()

def _disable_telemetry():
    """Disable Azure CLI telemetry collection."""
    result = shell.run("az config set core.collect_telemetry=false")
    if result.returncode != 0:
        # Non-fatal: log warning but continue
        log.warn("Failed to disable telemetry: " + result.stderr)

def _install_completions():
    """Install shell completions for Azure CLI."""

    # Determine user's shell
    user_shell = env.get("SHELL", "/bin/bash")

    if "bash" in user_shell:
        _install_bash_completions()
    elif "zsh" in user_shell:
        _install_zsh_completions()
    elif "fish" in user_shell:
        _install_fish_completions()

def _install_bash_completions():
    """Install bash completions for Azure CLI."""

    # Azure CLI provides completions via 'az completion'
    completions_dir = fs.home() + "/.local/share/bash-completion/completions"
    fs.mkdir(completions_dir, parents = True)

    completions_file = completions_dir + "/az"

    # Generate completions
    result = shell.run("az completion --shell bash")
    if result.returncode == 0:
        fs.write(completions_file, result.stdout)
        log.info("Installed bash completions to " + completions_file)
    else:
        log.warn("Failed to generate bash completions: " + result.stderr)

def _install_zsh_completions():
    """Install zsh completions for Azure CLI."""

    completions_dir = fs.home() + "/.local/share/zsh/site-functions"
    fs.mkdir(completions_dir, parents = True)

    completions_file = completions_dir + "/_az"

    result = shell.run("az completion --shell zsh")
    if result.returncode == 0:
        fs.write(completions_file, result.stdout)
        log.info("Installed zsh completions to " + completions_file)
    else:
        log.warn("Failed to generate zsh completions: " + result.stderr)

def _install_fish_completions():
    """Install fish completions for Azure CLI."""

    completions_dir = fs.home() + "/.config/fish/completions"
    fs.mkdir(completions_dir, parents = True)

    completions_file = completions_dir + "/az.fish"

    result = shell.run("az completion --shell fish")
    if result.returncode == 0:
        fs.write(completions_file, result.stdout)
        log.info("Installed fish completions to " + completions_file)
    else:
        log.warn("Failed to generate fish completions: " + result.stderr)

def _install_extensions():
    """Install commonly used Azure CLI extensions."""

    # Common extensions for cloud developers
    extensions = [
        "azure-devops",      # Azure DevOps integration
        "aks-preview",       # AKS preview features
        "ssh",               # SSH into VMs
        "containerapp",      # Container Apps
    ]

    for ext in extensions:
        result = shell.run("az extension add --name " + ext + " --yes")
        if result.returncode == 0:
            log.info("Installed extension: " + ext)
        else:
            # Non-fatal: some extensions may not be available
            log.warn("Failed to install extension " + ext + ": " + result.stderr)
