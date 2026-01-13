# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.

# provision.star - Provision phase for docker deploy pipeline
#
# This phase:
# 1. Detects hardware platform
# 2. Applies hardware-specific configuration (e.g., ODROID cgroup fix)
# 3. Adds user to docker group (optional)
#
# Logging API:
#   note(msg)    - informational, continues
#   warn(msg)    - warning, continues
#   error(msg)   - fails phase, triggers rollback
#   success(msg) - exits phase successfully

def main(lifecycle, state, features, settings):
    """Configure docker for this hardware."""

    note("Provisioning docker")

    # Detect hardware
    result = sudo("lshw -json")
    if not result.ok:
        warn("Could not detect hardware: " + result.stderr)
        product = "unknown"
    else:
        hw = json.parse(result.stdout)
        product = hw.get("product", "unknown") if hw else "unknown"

    note("Detected hardware: " + product)

    # Check for hardware-specific provisions
    provisions = lifecycle.get("hardware_provisions", {})
    needs_reboot = False
    manual_steps = []

    for hw_pattern, config in provisions.items():
        if product.startswith(hw_pattern):
            note("Applying provision for " + hw_pattern + ": " + config.get("description", ""))

            boot_arg = config.get("boot_arg")
            if boot_arg:
                # Check if boot.ini needs modification
                boot_ini = find_boot_ini()
                if boot_ini:
                    if not boot_arg_present(boot_ini, boot_arg):
                        manual_steps.append({
                            "description": "Add cgroup compatibility to boot.ini",
                            "file": boot_ini,
                            "action": "Append to bootargs: " + boot_arg,
                            "reference": config.get("reference", ""),
                        })
                        needs_reboot = True

    # Add current user to docker group (so sudo isn't always required)
    user = env("USER")
    if user and user != "root":
        result = run("groups " + user)
        if "docker" not in result.stdout:
            note("Adding " + user + " to docker group...")
            sudo("usermod -aG docker " + user)
            manual_steps.append({
                "description": "Log out and back in for docker group membership",
            })

    return {
        "hardware": product,
        "needs_reboot": needs_reboot,
        "manual_steps": manual_steps,
    }


def find_boot_ini():
    """Find boot.ini on the system."""
    result = sudo("find /media/boot -name boot.ini -type f 2>/dev/null")
    if result.ok and result.stdout:
        return result.stdout.strip().split("\n")[0]
    return None


def boot_arg_present(boot_ini, arg):
    """Check if boot argument is already in boot.ini."""
    result = sudo("grep -c '" + arg + "' '" + boot_ini + "'")
    return result.ok and int(result.stdout.strip() or "0") > 0
