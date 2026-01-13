# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# terraform/provision.star - Provision phase for Terraform

def provision():
    """Configure Terraform after installation."""

    # Install shell completions if enabled
    if package.feature("completions"):
        _install_completions()

    # Install additional tools if enabled
    if package.feature("tflint"):
        _install_tflint()

    if package.feature("terraform-docs"):
        _install_terraform_docs()

    if package.feature("tfsec"):
        _install_tfsec()

def _install_completions():
    """Install shell completions for Terraform."""

    # Terraform supports -install-autocomplete flag
    user_shell = env.get("SHELL", "/bin/bash")

    if "bash" in user_shell or "zsh" in user_shell:
        # Terraform can install its own completions
        result = shell.run("terraform -install-autocomplete 2>/dev/null", shell = True)
        if result.returncode == 0:
            log.info("Installed shell completions via terraform -install-autocomplete")
        else:
            # Manual installation
            _install_completions_manual()
    else:
        log.info("Shell completions not available for " + user_shell)

def _install_completions_manual():
    """Manually install shell completions."""

    user_shell = env.get("SHELL", "/bin/bash")

    if "bash" in user_shell:
        completions_dir = fs.home() + "/.local/share/bash-completion/completions"
        fs.mkdir(completions_dir, parents = True)

        # Terraform doesn't have a completion command, but we can create a basic one
        completion_content = """# Terraform bash completion
complete -C terraform terraform
"""
        fs.write(completions_dir + "/terraform", completion_content)
        log.info("Installed bash completions")

    elif "zsh" in user_shell:
        completions_dir = fs.home() + "/.local/share/zsh/site-functions"
        fs.mkdir(completions_dir, parents = True)

        completion_content = """#compdef terraform
# Terraform zsh completion
autoload -U +X bashcompinit && bashcompinit
complete -C terraform terraform
"""
        fs.write(completions_dir + "/_terraform", completion_content)
        log.info("Installed zsh completions")

def _install_tflint():
    """Install TFLint for Terraform static analysis."""
    # Reference: https://github.com/terraform-linters/tflint

    if shell.which("tflint"):
        log.info("tflint is already installed")
        return

    if platform.os == "darwin" and shell.which("brew"):
        result = shell.run("brew install tflint")
        if result.returncode == 0:
            log.info("Installed tflint via Homebrew")
            return

    # Install via script
    result = shell.run(
        "curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash",
        shell = True,
    )
    if result.returncode == 0:
        log.info("Installed tflint")
    else:
        log.warn("Failed to install tflint: " + result.stderr)

def _install_terraform_docs():
    """Install terraform-docs for documentation generation."""
    # Reference: https://github.com/terraform-docs/terraform-docs

    if shell.which("terraform-docs"):
        log.info("terraform-docs is already installed")
        return

    if platform.os == "darwin" and shell.which("brew"):
        result = shell.run("brew install terraform-docs")
        if result.returncode == 0:
            log.info("Installed terraform-docs via Homebrew")
            return

    # Direct download
    os_name = platform.os
    if os_name == "darwin":
        os_name = "darwin"
    elif os_name == "linux":
        os_name = "linux"
    else:
        log.warn("terraform-docs direct download not supported on " + os_name)
        return

    arch = platform.arch
    if arch == "amd64":
        arch = "amd64"
    elif arch == "arm64":
        arch = "arm64"

    # Get latest version
    result = shell.run("curl -s https://api.github.com/repos/terraform-docs/terraform-docs/releases/latest | grep tag_name")
    if result.returncode != 0:
        log.warn("Failed to get terraform-docs version")
        return

    version = ""
    for part in result.stdout.split('"'):
        if part.startswith("v"):
            version = part
            break

    if not version:
        log.warn("Could not parse terraform-docs version")
        return

    archive_name = "terraform-docs-" + version + "-" + os_name + "-" + arch + ".tar.gz"
    download_url = "https://github.com/terraform-docs/terraform-docs/releases/download/" + version + "/" + archive_name

    result = shell.run(
        "cd /tmp && " +
        "curl -fsSLO " + download_url + " && " +
        "tar xzf " + archive_name + " && " +
        "sudo mv terraform-docs /usr/local/bin/",
        shell = True,
    )

    if result.returncode == 0:
        log.info("Installed terraform-docs")
    else:
        log.warn("Failed to install terraform-docs: " + result.stderr)

def _install_tfsec():
    """Install tfsec for security scanning (deprecated in favor of trivy)."""
    # Reference: https://github.com/aquasecurity/tfsec

    if shell.which("tfsec"):
        log.info("tfsec is already installed")
        return

    log.warn("tfsec is deprecated. Consider using trivy instead: https://github.com/aquasecurity/trivy")

    if platform.os == "darwin" and shell.which("brew"):
        result = shell.run("brew install tfsec")
        if result.returncode == 0:
            log.info("Installed tfsec via Homebrew")
            return

    # Install via go if available
    if shell.which("go"):
        result = shell.run("go install github.com/aquasecurity/tfsec/cmd/tfsec@latest")
        if result.returncode == 0:
            log.info("Installed tfsec via go install")
            return

    log.warn("Could not install tfsec. Install manually or use trivy.")

def rollback():
    """Rollback provisioning changes on failure."""

    # Remove completions
    completions_files = [
        fs.home() + "/.local/share/bash-completion/completions/terraform",
        fs.home() + "/.local/share/zsh/site-functions/_terraform",
    ]

    for f in completions_files:
        if fs.exists(f):
            fs.remove(f)
