# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# astro/install.star - Install phase for Astro
#
# Uses npm.* runtime bindings for structured package management.

def install():
    """Install Astro CLI and tools."""

    state = {}

    # Install Astro CLI globally
    if package.feature("global-cli"):
        result = npm.install("astro", global=True)
        if not result.ok:
            _handle_npm_error(result)
        state["global_cli"] = True

    # Install create-astro for project scaffolding
    result = npm.install("create-astro", global=True)
    if not result.ok:
        warn("create-astro install failed: " + result.stderr)
    state["create_tool"] = result.ok

    # Install integration packages if requested
    integrations = []

    if package.feature("tailwind"):
        result = npm.install("@astrojs/tailwind", "tailwindcss", global=True)
        if result.ok:
            integrations.append("tailwind")

    if package.feature("react"):
        result = npm.install("@astrojs/react", "react", "react-dom", global=True)
        if result.ok:
            integrations.append("react")

    if package.feature("svelte"):
        result = npm.install("@astrojs/svelte", "svelte", global=True)
        if result.ok:
            integrations.append("svelte")

    if package.feature("vue"):
        result = npm.install("@astrojs/vue", "vue", global=True)
        if result.ok:
            integrations.append("vue")

    state["integrations"] = integrations
    return state

def _handle_npm_error(result):
    """Handle npm install errors with helpful messages."""

    stderr = result.stderr

    if "EACCES" in stderr or "permission" in stderr.lower():
        error(
            "Permission denied installing global npm packages.\n\n" +
            "Fix with one of:\n" +
            "  1. npm config set prefix '~/.npm-global' (then add to PATH)\n" +
            "  2. Use nvm/fnm to manage Node.js\n" +
            "  3. Use pnpm instead of npm"
        )
    else:
        error("npm install failed: " + stderr)

def rollback():
    """Rollback installation."""

    note("Rolling back Astro installation...")
    npm.uninstall("astro", "create-astro", global=True)

    if package.feature("tailwind"):
        npm.uninstall("@astrojs/tailwind", "tailwindcss", global=True)
    if package.feature("react"):
        npm.uninstall("@astrojs/react", "react", "react-dom", global=True)
    if package.feature("svelte"):
        npm.uninstall("@astrojs/svelte", "svelte", global=True)
    if package.feature("vue"):
        npm.uninstall("@astrojs/vue", "vue", global=True)
