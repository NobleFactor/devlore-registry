# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# gcloud/verify.star - Verify phase for Google Cloud CLI

def verify():
    """Verify Google Cloud CLI installation is working."""

    # Check that gcloud command exists
    gcloud_path = shell.which("gcloud")
    if not gcloud_path:
        fail("gcloud command not found in PATH")

    # Check version output
    result = shell.run("gcloud --version")
    if result.returncode != 0:
        fail("'gcloud --version' failed: " + result.stderr)

    # Parse version
    version = _parse_version(result.stdout)
    if not version:
        fail("Could not parse Google Cloud SDK version from output")

    log.info("Google Cloud SDK version " + version + " is installed")

    # Verify components
    components_installed = _verify_components()

    # Verify completions if enabled
    if package.feature("completions"):
        _verify_completions()

    # Return success info for receipt
    return {
        "version": version,
        "path": gcloud_path,
        "components": components_installed,
        "completions": package.feature("completions"),
    }

def _parse_version(output):
    """Parse version string from gcloud version output."""
    # Output looks like:
    # Google Cloud SDK 503.0.0
    # bq 2.1.10
    # core 2024.12.13
    # gcloud-crc32c 1.0.0
    # gsutil 5.32
    for line in output.split("\n"):
        if line.startswith("Google Cloud SDK"):
            parts = line.split()
            if len(parts) >= 4:
                return parts[3]
    return None

def _verify_components():
    """Verify requested components are installed."""

    components_to_check = []

    if package.feature("kubectl"):
        components_to_check.append("kubectl")

    if package.feature("gke-auth"):
        components_to_check.append("gke-gcloud-auth-plugin")

    if package.feature("bq"):
        components_to_check.append("bq")

    if package.feature("gsutil"):
        components_to_check.append("gsutil")

    installed = []

    for component in components_to_check:
        # Check if command exists or component is listed
        if shell.which(component):
            log.info("Component installed: " + component)
            installed.append(component)
        else:
            # Check via gcloud components list
            result = shell.run("gcloud components list --filter='id:" + component + " AND state.name:Installed' --format='value(id)'")
            if result.returncode == 0 and component in result.stdout:
                log.info("Component installed: " + component)
                installed.append(component)
            else:
                log.warn("Component not found: " + component)

    return installed

def _verify_completions():
    """Verify shell completions are configured."""

    user_shell = env.get("SHELL", "/bin/bash")

    if "bash" in user_shell:
        completions_file = fs.home() + "/.local/share/bash-completion/completions/gcloud"
    elif "zsh" in user_shell:
        completions_file = fs.home() + "/.local/share/zsh/site-functions/_gcloud"
    else:
        return

    if fs.exists(completions_file):
        log.info("Shell completions installed: " + completions_file)
    else:
        log.warn("Shell completions file not found: " + completions_file)

        # Check if completions are sourced from SDK directory
        sdk_dir = _find_sdk_dir()
        if sdk_dir:
            if "bash" in user_shell:
                source_file = sdk_dir + "/completion.bash.inc"
            else:
                source_file = sdk_dir + "/completion.zsh.inc"

            if fs.exists(source_file):
                log.info("Completions available at: " + source_file)
                log.info("Add to your shell config: source '" + source_file + "'")

def _find_sdk_dir():
    """Find the Google Cloud SDK installation directory."""

    result = shell.run("gcloud info --format='value(installation.sdk_root)'")
    if result.returncode == 0 and result.stdout.strip():
        return result.stdout.strip()

    # Common locations
    locations = [
        fs.home() + "/google-cloud-sdk",
        "/usr/lib/google-cloud-sdk",
        "/usr/share/google-cloud-sdk",
    ]

    for loc in locations:
        if fs.exists(loc):
            return loc

    return None
