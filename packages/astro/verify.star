# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# astro/verify.star - Verify phase for Astro
#
# Uses npm.* runtime bindings for package verification.

def verify():
    """Verify Astro installation is working."""

    state = {}

    # Check astro CLI via npm
    if package.feature("global-cli"):
        if not npm.installed("astro"):
            error("astro not found in global npm packages")

        version = npm.version("astro")
        if version:
            state["astro_version"] = version
            note("Astro CLI: " + version)
        else:
            error("Could not determine astro version")

    # Check create-astro
    if npm.installed("create-astro"):
        version = npm.version("create-astro")
        state["create_astro"] = version
        note("create-astro: " + version)
    else:
        note("create-astro not installed globally (use npx)")

    # Check Node.js
    result = shell.exec("node --version")
    if result.ok:
        state["node_version"] = result.stdout.strip()

    # Verify completions if enabled
    if package.feature("completions"):
        state["completions"] = _check_completions()

    # Show npm global prefix for debugging
    prefix = npm.prefix()
    if prefix:
        note("npm global prefix: " + prefix)

    note("")
    note("Verification complete")
    return state

def _check_completions():
    """Check if completions are installed."""

    shell_path = env.get("SHELL", "")

    if "bash" in shell_path:
        path = fs.join(fs.home(), ".local/share/bash-completion/completions/astro")
    elif "zsh" in shell_path:
        path = fs.join(fs.home(), ".local/share/zsh/site-functions/_astro")
    elif "fish" in shell_path:
        path = fs.join(fs.home(), ".config/fish/completions/astro.fish")
    else:
        return False

    exists = fs.exists(path)
    if exists:
        note("Completions: " + path)
    return exists
