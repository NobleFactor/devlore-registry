# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# gcloud/provision.star - Provision phase for Google Cloud CLI

def provision():
    """Configure Google Cloud CLI after installation."""

    # Install additional components based on features
    if package.feature("kubectl"):
        _install_component("kubectl")

    if package.feature("gke-auth"):
        _install_component("gke-gcloud-auth-plugin")

    if package.feature("app-engine"):
        _install_app_engine_components()

    # bq and gsutil are included by default, but ensure they're present
    if package.feature("bq"):
        _ensure_component("bq")

    if package.feature("gsutil"):
        _ensure_component("gsutil")

    # Configure default settings
    _configure_defaults()

    # Install shell completions if enabled
    if package.feature("completions"):
        _install_completions()

def _install_component(component):
    """Install a gcloud component."""

    result = shell.run("gcloud components install " + component + " --quiet")
    if result.returncode == 0:
        log.info("Installed gcloud component: " + component)
    else:
        log.warn("Failed to install component " + component + ": " + result.stderr)

def _ensure_component(component):
    """Ensure a component is installed."""

    result = shell.run("gcloud components list --filter='id:" + component + " AND state.name:Installed' --format='value(id)'")
    if result.returncode == 0 and component in result.stdout:
        log.info("Component already installed: " + component)
    else:
        _install_component(component)

def _install_app_engine_components():
    """Install App Engine components."""

    components = [
        "app-engine-python",
        "app-engine-python-extras",
        "app-engine-java",
        "app-engine-go",
    ]

    for component in components:
        _install_component(component)

def _configure_defaults():
    """Configure default project, region, and zone if specified."""

    project = package.setting("project", "")
    if project:
        result = shell.run("gcloud config set project " + project)
        if result.returncode == 0:
            log.info("Set default project: " + project)
        else:
            log.warn("Failed to set project: " + result.stderr)

    region = package.setting("region", "")
    if region:
        result = shell.run("gcloud config set compute/region " + region)
        if result.returncode == 0:
            log.info("Set default region: " + region)
        else:
            log.warn("Failed to set region: " + result.stderr)

    zone = package.setting("zone", "")
    if zone:
        result = shell.run("gcloud config set compute/zone " + zone)
        if result.returncode == 0:
            log.info("Set default zone: " + zone)
        else:
            log.warn("Failed to set zone: " + result.stderr)

def _install_completions():
    """Install shell completions for gcloud."""

    user_shell = env.get("SHELL", "/bin/bash")

    # gcloud provides completion scripts in its installation
    # Find the SDK directory
    sdk_dir = _find_sdk_dir()

    if not sdk_dir:
        log.warn("Could not find Google Cloud SDK directory for completions")
        return

    if "bash" in user_shell:
        _install_bash_completions(sdk_dir)
    elif "zsh" in user_shell:
        _install_zsh_completions(sdk_dir)
    elif "fish" in user_shell:
        _install_fish_completions()

def _find_sdk_dir():
    """Find the Google Cloud SDK installation directory."""

    # Common locations
    locations = [
        fs.home() + "/google-cloud-sdk",
        "/usr/lib/google-cloud-sdk",
        "/usr/share/google-cloud-sdk",
        "/opt/google-cloud-sdk",
    ]

    # Check brew cask location on macOS
    if platform.os == "darwin":
        locations.append("/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk")
        locations.append("/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk")

    for loc in locations:
        if fs.exists(loc):
            return loc

    # Try to find via gcloud
    result = shell.run("gcloud info --format='value(installation.sdk_root)'")
    if result.returncode == 0 and result.stdout.strip():
        return result.stdout.strip()

    return None

def _install_bash_completions(sdk_dir):
    """Install bash completions for gcloud."""

    completions_dir = fs.home() + "/.local/share/bash-completion/completions"
    fs.mkdir(completions_dir, parents = True)

    # gcloud provides completion.bash.inc
    source_file = sdk_dir + "/completion.bash.inc"
    if fs.exists(source_file):
        # Create a sourcing script
        completion_content = "# Source gcloud completions\nsource '" + source_file + "'\n"
        fs.write(completions_dir + "/gcloud", completion_content)
        log.info("Installed bash completions for gcloud")
    else:
        log.warn("gcloud completion script not found: " + source_file)

def _install_zsh_completions(sdk_dir):
    """Install zsh completions for gcloud."""

    completions_dir = fs.home() + "/.local/share/zsh/site-functions"
    fs.mkdir(completions_dir, parents = True)

    # gcloud provides completion.zsh.inc
    source_file = sdk_dir + "/completion.zsh.inc"
    if fs.exists(source_file):
        completion_content = "# Source gcloud completions\nsource '" + source_file + "'\n"
        fs.write(completions_dir + "/_gcloud", completion_content)
        log.info("Installed zsh completions for gcloud")
    else:
        log.warn("gcloud completion script not found: " + source_file)

def _install_fish_completions():
    """Install fish completions for gcloud (not officially supported)."""
    log.info("Fish completions for gcloud are not officially supported")

