# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# astro/provision.star - Provision phase for Astro
#
# TRIBAL KNOWLEDGE:
# - Astro doesn't ship official shell completions (as of v5.x)
# - We generate basic completions from known command structure

# Astro CLI commands for completion generation
ASTRO_COMMANDS = [
    ("add", "Add integrations to your project"),
    ("build", "Build your site for production"),
    ("check", "Check your project for errors"),
    ("dev", "Start the development server"),
    ("docs", "Open Astro documentation"),
    ("info", "Show environment info"),
    ("preview", "Preview your build locally"),
    ("sync", "Sync content collections"),
]

def provision():
    """Configure Astro after installation."""

    state = {}

    if package.feature("completions"):
        state["completions"] = _install_completions()
    else:
        state["completions"] = False

    _show_usage()
    return state

def _install_completions():
    """Install shell completions for Astro."""

    shell_path = env.get("SHELL", "")

    if "bash" in shell_path:
        return _bash_completions()
    elif "zsh" in shell_path:
        return _zsh_completions()
    elif "fish" in shell_path:
        return _fish_completions()
    else:
        note("Shell completions not available for: " + shell_path)
        return False

def _bash_completions():
    """Generate bash completions."""

    dir = fs.join(fs.home(), ".local/share/bash-completion/completions")
    fs.mkdir(dir, parents=True)

    commands = " ".join([cmd for cmd, _ in ASTRO_COMMANDS])
    script = '''_astro() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    if [ ${COMP_CWORD} -eq 1 ]; then
        COMPREPLY=($(compgen -W "''' + commands + '''" -- "${cur}"))
    fi
}
complete -F _astro astro
'''

    path = fs.join(dir, "astro")
    if fs.write(path, script):
        note("Installed bash completions: " + path)
        return True
    return False

def _zsh_completions():
    """Generate zsh completions."""

    dir = fs.join(fs.home(), ".local/share/zsh/site-functions")
    fs.mkdir(dir, parents=True)

    lines = ["#compdef astro", "", "_astro() {", "    local -a commands", "    commands=("]
    for cmd, desc in ASTRO_COMMANDS:
        lines.append("        '" + cmd + ":" + desc + "'")
    lines.extend(["    )", "", "    _describe 'astro commands' commands", "}", "", "_astro"])

    path = fs.join(dir, "_astro")
    if fs.write(path, "\n".join(lines)):
        note("Installed zsh completions: " + path)
        return True
    return False

def _fish_completions():
    """Generate fish completions."""

    dir = fs.join(fs.home(), ".config/fish/completions")
    fs.mkdir(dir, parents=True)

    lines = ["# Astro completions"]
    for cmd, desc in ASTRO_COMMANDS:
        lines.append("complete -c astro -n '__fish_use_subcommand' -a '" + cmd + "' -d '" + desc + "'")

    path = fs.join(dir, "astro.fish")
    if fs.write(path, "\n".join(lines) + "\n"):
        note("Installed fish completions: " + path)
        return True
    return False

def _show_usage():
    """Display usage hints."""

    note("")
    note("Astro is ready!")
    note("")
    note("  Create a project:  npm create astro@latest")
    note("  Start dev server:  astro dev")
    note("  Build for prod:    astro build")
    note("  Add integration:   astro add tailwind")
    note("")
