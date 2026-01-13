# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# azure-cli/verify.star - Verify phase for Azure CLI
#
# This phase proves the installation is working.

def verify():
    """Verify Azure CLI installation is working."""

    # Check that az command exists
    if not shell.which("az"):
        fail("Azure CLI command 'az' not found in PATH")

    # Check version output
    result = shell.run("az --version")
    if result.returncode != 0:
        fail("'az --version' failed: " + result.stderr)

    # Parse version from output
    version = _parse_version(result.stdout)
    if not version:
        fail("Could not parse Azure CLI version from output")

    log.info("Azure CLI version " + version + " is installed")

    # Verify completions if enabled
    if package.feature("completions"):
        _verify_completions()

    # Return success info for receipt
    return {
        "version": version,
        "path": shell.which("az"),
        "completions": package.feature("completions"),
        "extensions": package.feature("extensions"),
    }

def _parse_version(output):
    """Parse version string from 'az --version' output."""
    # Output looks like:
    # azure-cli                         2.81.0
    # ...
    for line in output.split("\n"):
        if line.startswith("azure-cli"):
            parts = line.split()
            if len(parts) >= 2:
                return parts[-1]
    return None

def _verify_completions():
    """Verify shell completions are installed."""

    user_shell = env.get("SHELL", "/bin/bash")

    if "bash" in user_shell:
        completions_file = fs.home() + "/.local/share/bash-completion/completions/az"
    elif "zsh" in user_shell:
        completions_file = fs.home() + "/.local/share/zsh/site-functions/_az"
    elif "fish" in user_shell:
        completions_file = fs.home() + "/.config/fish/completions/az.fish"
    else:
        return  # Unknown shell, skip verification

    if not fs.exists(completions_file):
        log.warn("Shell completions file not found: " + completions_file)
    else:
        log.info("Shell completions installed: " + completions_file)
