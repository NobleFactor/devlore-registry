# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# aws-cli/verify.star - Verify phase for AWS CLI v2
#
# This phase proves the installation is working.

def verify():
    """Verify AWS CLI v2 installation is working."""

    # Check that aws command exists
    aws_path = shell.which("aws")
    if not aws_path:
        fail("AWS CLI command 'aws' not found in PATH")

    # Check version output
    result = shell.run("aws --version")
    if result.returncode != 0:
        fail("'aws --version' failed: " + result.stderr)

    # Verify it's v2
    version = _parse_version(result.stdout)
    if not version:
        fail("Could not parse AWS CLI version from output")

    if not version.startswith("2."):
        fail("Expected AWS CLI v2, got version " + version)

    log.info("AWS CLI version " + version + " is installed")

    # Verify completions if enabled
    if package.feature("completions"):
        _verify_completions()

    # Verify Session Manager plugin if enabled
    if package.feature("session-manager"):
        _verify_session_manager()

    # Return success info for receipt
    return {
        "version": version,
        "path": aws_path,
        "completions": package.feature("completions"),
        "session_manager": package.feature("session-manager"),
    }

def _parse_version(output):
    """Parse version string from 'aws --version' output."""
    # Output looks like:
    # aws-cli/2.22.0 Python/3.12.6 Darwin/24.2.0 source/arm64
    parts = output.strip().split()
    if len(parts) >= 1 and parts[0].startswith("aws-cli/"):
        return parts[0].replace("aws-cli/", "")
    return None

def _verify_completions():
    """Verify shell completions are installed."""

    # Check for aws_completer
    if not shell.which("aws_completer"):
        log.warn("aws_completer not found in PATH")
        return

    user_shell = env.get("SHELL", "/bin/bash")

    if "bash" in user_shell:
        completions_file = fs.home() + "/.local/share/bash-completion/completions/aws"
    elif "zsh" in user_shell:
        completions_file = fs.home() + "/.local/share/zsh/site-functions/_aws"
    else:
        return  # Unknown shell, skip verification

    if not fs.exists(completions_file):
        log.warn("Shell completions file not found: " + completions_file)
    else:
        log.info("Shell completions installed: " + completions_file)

def _verify_session_manager():
    """Verify Session Manager plugin is installed."""

    if shell.which("session-manager-plugin"):
        result = shell.run("session-manager-plugin --version")
        if result.returncode == 0:
            log.info("Session Manager plugin installed: " + result.stdout.strip())
        else:
            log.warn("Session Manager plugin found but version check failed")
    else:
        log.warn("Session Manager plugin not found in PATH")
