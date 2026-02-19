# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# aws-cli/provision.star - Provision phase for AWS CLI v2
#
# This phase configures the installed software.

def provision():
    """Configure AWS CLI after installation."""

    # Install shell completions if enabled
    if package.feature("completions"):
        _install_completions()

    # Configure default output format if specified
    output_format = package.setting("output", "")
    if output_format:
        _configure_output_format(output_format)

    # Configure default region if specified
    region = package.setting("region", "")
    if region:
        _configure_region(region)

    # Install Session Manager plugin if enabled
    if package.feature("session-manager"):
        _install_session_manager()

def _install_completions():
    """Install shell completions for AWS CLI."""

    # AWS CLI v2 includes aws_completer
    completer_path = shell.which("aws_completer")
    if not completer_path:
        # Try common locations
        if fs.exists("/usr/local/bin/aws_completer"):
            completer_path = "/usr/local/bin/aws_completer"
        elif fs.exists("/usr/local/aws-cli/v2/current/bin/aws_completer"):
            completer_path = "/usr/local/aws-cli/v2/current/bin/aws_completer"

    if not completer_path:
        log.warn("aws_completer not found; skipping completions")
        return

    user_shell = env.get("SHELL", "/bin/bash")

    if "bash" in user_shell:
        _install_bash_completions(completer_path)
    elif "zsh" in user_shell:
        _install_zsh_completions(completer_path)

def _install_bash_completions(completer_path):
    """Install bash completions for AWS CLI."""

    completions_dir = fs.home() + "/.local/share/bash-completion/completions"
    fs.mkdir(completions_dir, parents = True)

    completions_file = completions_dir + "/aws"

    # AWS uses a completer script approach
    completion_content = """# AWS CLI bash completion
complete -C '""" + completer_path + """' aws
"""

    fs.write(completions_file, completion_content)
    log.info("Installed bash completions to " + completions_file)

def _install_zsh_completions(completer_path):
    """Install zsh completions for AWS CLI."""

    completions_dir = fs.home() + "/.local/share/zsh/site-functions"
    fs.mkdir(completions_dir, parents = True)

    completions_file = completions_dir + "/_aws"

    # For zsh, we need to use bashcompinit
    completion_content = """#compdef aws
# AWS CLI zsh completion

autoload -Uz bashcompinit && bashcompinit
complete -C '""" + completer_path + """' aws
"""

    fs.write(completions_file, completion_content)
    log.info("Installed zsh completions to " + completions_file)

def _configure_output_format(output_format):
    """Configure default output format."""

    valid_formats = ["json", "yaml", "yaml-stream", "text", "table"]
    if output_format not in valid_formats:
        log.warn("Invalid output format: " + output_format + ". Valid: " + ", ".join(valid_formats))
        return

    result = shell.run("aws configure set output " + output_format)
    if result.returncode == 0:
        log.info("Set default output format to " + output_format)
    else:
        log.warn("Failed to set output format: " + result.stderr)

def _configure_region(region):
    """Configure default AWS region."""

    result = shell.run("aws configure set region " + region)
    if result.returncode == 0:
        log.info("Set default region to " + region)
    else:
        log.warn("Failed to set region: " + result.stderr)

def _install_session_manager():
    """Install AWS Session Manager plugin."""

    if platform.os == "darwin":
        _install_session_manager_darwin()
    elif platform.os == "linux":
        _install_session_manager_linux()
    elif platform.os == "windows":
        _install_session_manager_windows()

def _install_session_manager_darwin():
    """Install Session Manager plugin on macOS."""

    if shell.which("brew"):
        # Homebrew has a cask
        result = shell.run("brew install --cask session-manager-plugin")
        if result.returncode != 0:
            log.warn("Failed to install Session Manager plugin via Homebrew")
    else:
        # Manual installation
        pkg_url = "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac/sessionmanager-bundle.zip"
        log.warn("Session Manager plugin requires manual installation from: " + pkg_url)

def _install_session_manager_linux():
    """Install Session Manager plugin on Linux."""

    arch = platform.arch
    if arch == "amd64":
        arch_suffix = "64bit"
    elif arch == "arm64":
        arch_suffix = "arm64"
    else:
        log.warn("Session Manager plugin not available for architecture: " + arch)
        return

    if platform.distro in ["debian", "ubuntu"]:
        deb_url = "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_" + arch_suffix + "/session-manager-plugin.deb"
        deb_path = "/tmp/session-manager-plugin.deb"

        result = shell.run("curl -o " + deb_path + " " + deb_url)
        if result.returncode == 0:
            result = shell.run("sudo dpkg -i " + deb_path)
            if result.returncode == 0:
                log.info("Installed Session Manager plugin")
            fs.remove(deb_path)
        else:
            log.warn("Failed to download Session Manager plugin")

    elif platform.distro in ["fedora", "rhel", "centos"]:
        rpm_url = "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_" + arch_suffix + "/session-manager-plugin.rpm"
        rpm_path = "/tmp/session-manager-plugin.rpm"

        result = shell.run("curl -o " + rpm_path + " " + rpm_url)
        if result.returncode == 0:
            result = shell.run("sudo rpm -i " + rpm_path)
            if result.returncode == 0:
                log.info("Installed Session Manager plugin")
            fs.remove(rpm_path)
        else:
            log.warn("Failed to download Session Manager plugin")

def _install_session_manager_windows():
    """Install Session Manager plugin on Windows."""
    log.info("Session Manager plugin: download from https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html")
