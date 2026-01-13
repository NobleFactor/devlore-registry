# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# terraform/verify.star - Verify phase for Terraform

def verify():
    """Verify Terraform installation is working."""

    # Check that terraform command exists
    terraform_path = shell.which("terraform")
    if not terraform_path:
        fail("terraform command not found in PATH")

    # Check version output
    result = shell.run("terraform --version")
    if result.returncode != 0:
        fail("'terraform --version' failed: " + result.stderr)

    # Parse version
    version = _parse_version(result.stdout)
    if not version:
        fail("Could not parse Terraform version from output")

    log.info("Terraform version " + version + " is installed")

    # Verify completions
    if package.feature("completions"):
        _verify_completions()

    # Verify additional tools if enabled
    if package.feature("tflint"):
        _verify_tflint()

    if package.feature("terraform-docs"):
        _verify_terraform_docs()

    # Return success info for receipt
    return {
        "version": version,
        "path": terraform_path,
        "completions": package.feature("completions"),
        "tflint": package.feature("tflint") and shell.which("tflint") != None,
        "terraform_docs": package.feature("terraform-docs") and shell.which("terraform-docs") != None,
    }

def _parse_version(output):
    """Parse version string from terraform version output."""
    # Output looks like:
    # Terraform v1.10.0
    # on darwin_arm64
    for line in output.split("\n"):
        if line.startswith("Terraform v"):
            return line.replace("Terraform ", "").strip()
    return None

def _verify_completions():
    """Verify shell completions are configured."""

    user_shell = env.get("SHELL", "/bin/bash")

    if "bash" in user_shell:
        # Check for completion in .bashrc or completion file
        bashrc = fs.home() + "/.bashrc"
        completions_file = fs.home() + "/.local/share/bash-completion/completions/terraform"

        if fs.exists(completions_file):
            log.info("Shell completions installed: " + completions_file)
        elif fs.exists(bashrc):
            content = fs.read(bashrc)
            if "complete -C" in content and "terraform" in content:
                log.info("Shell completions configured in .bashrc")
            else:
                log.warn("Shell completions may not be configured")

    elif "zsh" in user_shell:
        completions_file = fs.home() + "/.local/share/zsh/site-functions/_terraform"
        zshrc = fs.home() + "/.zshrc"

        if fs.exists(completions_file):
            log.info("Shell completions installed: " + completions_file)
        elif fs.exists(zshrc):
            content = fs.read(zshrc)
            if "complete -C" in content and "terraform" in content:
                log.info("Shell completions configured in .zshrc")
            else:
                log.warn("Shell completions may not be configured")

def _verify_tflint():
    """Verify tflint is installed."""

    if shell.which("tflint"):
        result = shell.run("tflint --version")
        if result.returncode == 0:
            log.info("tflint is installed: " + result.stdout.strip().split("\n")[0])
        else:
            log.warn("tflint found but version check failed")
    else:
        log.warn("tflint was requested but not found")

def _verify_terraform_docs():
    """Verify terraform-docs is installed."""

    if shell.which("terraform-docs"):
        result = shell.run("terraform-docs --version")
        if result.returncode == 0:
            log.info("terraform-docs is installed: " + result.stdout.strip())
        else:
            log.warn("terraform-docs found but version check failed")
    else:
        log.warn("terraform-docs was requested but not found")
