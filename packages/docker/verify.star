# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.

# verify.star - Verify phase for docker deploy pipeline
#
# This phase:
# 1. Checks docker daemon is running
# 2. Runs hello-world container
# 3. Reports any manual steps from provision phase
# 4. Returns state for pipeline-receipt generation
#
# Logging API:
#   note(msg)    - informational, continues
#   warn(msg)    - warning, continues
#   error(msg)   - fails phase, triggers rollback
#   success(msg) - exits phase successfully

def main(lifecycle, state, features, settings):
    """Verify docker deployment and generate receipt data."""

    note("Verifying docker deployment")

    checks_passed = []
    checks_failed = []

    # Check 1: docker command exists
    result = run("command -v docker")
    if result.ok:
        checks_passed.append("docker command found: " + result.stdout)
    else:
        checks_failed.append("docker command not found")

    # Check 2: docker daemon is running
    result = sudo("docker info")
    if result.ok:
        checks_passed.append("docker daemon is running")
    else:
        checks_failed.append("docker daemon not running: " + result.stderr)

    # Check 3: docker compose available
    result = run("docker compose version")
    if result.ok:
        checks_passed.append("docker compose: " + result.stdout.split("\n")[0])
    else:
        checks_failed.append("docker compose not available")

    # Check 4: run hello-world (skip if reboot needed)
    if state.get("needs_reboot"):
        note("Skipping hello-world test (reboot required first)")
    else:
        note("Running hello-world container...")
        result = sudo("docker run --rm hello-world")
        if result.ok:
            checks_passed.append("hello-world container ran successfully")
        else:
            checks_failed.append("hello-world failed: " + result.stderr)

    # Report results
    note("")
    note("=== Verification Results ===")
    for check in checks_passed:
        note("  [PASS] " + check)
    for check in checks_failed:
        warn("  [FAIL] " + check)

    # Report manual steps
    manual_steps = state.get("manual_steps", [])
    if len(manual_steps) > 0:
        note("")
        note("=== Manual Steps Required ===")
        for i, step in enumerate(manual_steps):
            note("")
            note(str(i + 1) + ". " + step.get("description", ""))
            if step.get("file"):
                note("   File: " + step["file"])
            if step.get("action"):
                note("   Action: " + step["action"])
            if step.get("reference"):
                note("   Reference: " + step["reference"])

    if state.get("needs_reboot"):
        note("")
        note("=== Reboot Required ===")
        note("Run: sudo reboot now")
        note("Then verify with: sudo docker run hello-world")

    # Determine outcome
    if len(checks_failed) > 0:
        error("Verification failed: %d checks failed" % len(checks_failed))

    # Get version info for receipt
    version_result = run("docker --version")
    docker_version = version_result.stdout.strip() if version_result.ok else "unknown"

    # Return state for pipeline-receipt
    success("docker deployed successfully", {
        "package": lifecycle.get("name", "docker"),
        "version": docker_version,
        "features": features,
        "settings": settings,
        "checks_passed": len(checks_passed),
        "checks_failed": len(checks_failed),
        "manual_steps": manual_steps,
        "needs_reboot": state.get("needs_reboot", False),
        "packages_installed": state.get("packages_installed", []),
    })
