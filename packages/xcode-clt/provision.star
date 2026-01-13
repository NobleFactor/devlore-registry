# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# xcode-clt/provision.star - Provision phase for Xcode Command Line Tools
#
# TRIBAL KNOWLEDGE:
#
# 1. LICENSE ACCEPTANCE
#    After installation, you must accept the Xcode license before the tools
#    will work. This is done via `sudo xcodebuild -license accept`.
#    Without this, many tools will refuse to run with an error about
#    "agreeing to the Xcode/iOS license".
#
# 2. FIRST-RUN SETUP
#    Some tools perform first-run setup. Running a simple command like
#    `clang --version` ensures this completes before the verify phase.
#
# 3. HOMEBREW COMPATIBILITY
#    Homebrew expects CLT at /Library/Developer/CommandLineTools and checks
#    `xcode-select -p`. We ensure this is configured correctly.
#
# 4. CCACHE AND BUILD TOOLS
#    If ccache or other compiler wrappers are in use, they should be configured
#    after CLT installation to point to the new compiler paths.
#
# 5. GIT CREDENTIAL HELPER
#    macOS CLT includes git with the osxkeychain credential helper, but this
#    may need explicit configuration for some setups.

_CLT_PATH = "/Library/Developer/CommandLineTools"


def provision():
    """Configure Xcode Command Line Tools after installation."""

    state = lore.state()

    # If already installed and nothing changed, minimal provisioning
    if state.get("already_installed", False):
        note("CLT was already installed; performing minimal provisioning")
        _accept_license()
        return state

    # Accept the Xcode/CLT license
    _accept_license()

    # Trigger first-run initialization
    _trigger_first_run()

    # Verify xcode-select configuration
    _verify_xcode_select()

    # Configure git credential helper (optional but helpful)
    _configure_git_credential_helper()

    note("Xcode Command Line Tools provisioning complete")

    return {
        "provisioned": True,
        "license_accepted": True,
    }


def _accept_license():
    """Accept the Xcode/CLT license agreement.

    TRIBAL KNOWLEDGE:
    - Both Xcode.app and standalone CLT have license agreements
    - Without acceptance, tools print license error and refuse to run
    - xcodebuild -license accept requires root but works silently
    - The license is stored in a plist and persists across reboots

    Common error without acceptance:
    "Agreeing to the Xcode/iOS license requires admin privileges,
     please run 'sudo xcodebuild -license' and then retry this command."
    """

    note("Accepting Xcode license agreement...")

    # Check if xcodebuild exists (it's part of CLT)
    xcodebuild = fs.which("xcodebuild")

    if not xcodebuild:
        # Try the full path
        xcodebuild = _CLT_PATH + "/usr/bin/xcodebuild"
        if not fs.exists(xcodebuild):
            # No xcodebuild means license acceptance isn't needed (minimal CLT)
            note("xcodebuild not found; license acceptance not required")
            return

    # Accept the license non-interactively
    result = shell.exec(
        command = xcodebuild + " -license accept",
        allowed_commands = ["xcodebuild"],
    )

    if result.ok:
        note("License accepted")
    else:
        # License may already be accepted, or this is a minimal CLT without xcodebuild
        if "already agreed" in result.stderr.lower():
            note("License already accepted")
        elif "no xcode" in result.stderr.lower():
            # Standalone CLT without Xcode - this is fine
            note("Standalone CLT; no additional license required")
        else:
            warn("Could not accept license: " + result.stderr)
            warn("You may need to run 'sudo xcodebuild -license accept' manually")


def _trigger_first_run():
    """Trigger first-run initialization of CLT tools.

    Some tools perform setup on first execution. Running them now ensures
    the verify phase doesn't encounter initialization delays or prompts.
    """

    note("Initializing Command Line Tools...")

    # Run clang to trigger any first-run setup
    result = shell.exec(
        command = "clang --version",
        allowed_commands = ["clang"],
    )

    if not result.ok:
        warn("clang initialization returned error: " + result.stderr)

    # Run git to initialize its first-run config
    result = shell.exec(
        command = "git --version",
        allowed_commands = ["git"],
    )

    if not result.ok:
        warn("git initialization returned error: " + result.stderr)


def _verify_xcode_select():
    """Verify xcode-select is pointing to the right location."""

    result = shell.exec(
        command = "xcode-select -p",
        allowed_commands = ["xcode-select"],
    )

    if not result.ok:
        warn("xcode-select not configured: " + result.stderr)
        return

    current_path = result.stdout.strip()
    note("xcode-select path: " + current_path)

    # Verify it's valid
    if not fs.exists(current_path):
        warn("xcode-select path does not exist: " + current_path)
        # Try to reset to default
        shell.exec(
            command = "xcode-select --switch " + _CLT_PATH,
            allowed_commands = ["xcode-select"],
        )


def _configure_git_credential_helper():
    """Configure git to use the macOS keychain credential helper.

    TRIBAL KNOWLEDGE:
    The CLT includes a git credential helper that integrates with macOS Keychain.
    This allows git to securely store and retrieve credentials without prompting
    for passwords repeatedly.

    The helper is at: /Library/Developer/CommandLineTools/usr/share/git-core/gitconfig
    But it's better to configure it explicitly in the user's gitconfig.
    """

    # Check if git is available
    git_path = fs.which("git")
    if not git_path:
        note("git not found; skipping credential helper configuration")
        return

    # Check current credential helper configuration
    result = shell.exec(
        command = "git config --global credential.helper",
        allowed_commands = ["git"],
    )

    current_helper = result.stdout.strip() if result.ok else ""

    # If osxkeychain is already configured, we're done
    if current_helper == "osxkeychain":
        note("git credential helper already configured: osxkeychain")
        return

    # If another helper is configured, don't override it
    if current_helper:
        note("git credential helper already configured: " + current_helper)
        return

    # Configure osxkeychain helper
    note("Configuring git to use osxkeychain credential helper")
    result = shell.exec(
        command = "git config --global credential.helper osxkeychain",
        allowed_commands = ["git"],
    )

    if result.ok:
        note("git credential helper configured")
    else:
        warn("Failed to configure git credential helper: " + result.stderr)


def rollback():
    """Rollback provisioning changes on failure.

    Most provisioning changes are configuration rather than files,
    so there's limited rollback capability.
    """

    # There's no way to "un-accept" the license, and that's fine
    # Git config changes are minor and don't need rollback

    note("Provisioning rollback complete (no changes to undo)")
