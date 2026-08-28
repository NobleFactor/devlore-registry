# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Noble Factor. All rights reserved.
#
# docker/Darwin/Deploy/provision.star — Provision phase
#
# TRIBAL KNOWLEDGE:
#
# There is no plan.service.* on this path. Colima is a VM manager started in the foreground, not a
# launchd service registered under the name "docker", so the service provider has nothing to enable.
#
# The flags are the substance of this phase. Install-Dependencies passes only --cpu 2 --memory 4,
# which leaves the VM type and mount type at their defaults:
#
#   --vm-type vz          Apple's Virtualization.framework rather than QEMU
#   --mount-type virtiofs Closes most of the bind-mount performance gap with Docker Desktop
#   --vz-rosetta          Makes x86_64 images tolerable on Apple Silicon
#
# Without vz and virtiofs, file sharing falls back to a slower transport, which is the complaint
# people usually attribute to Colima itself. 4GB is also thin for anything past hello-world.
#
# The guard mirrors install: start Colima only where Colima is the runtime. Starting it on a machine
# whose daemon is OrbStack or Docker Desktop would raise a second, redundant VM.
#
# KNOWN IMPRECISION: the predicate asks whether Colima is installed, not whether this deployment
# installed it. A machine carrying both OrbStack and a pre-existing Colima will start Colima here.
# Distinguishing the two needs the deploy receipt, which is not readable from a phase script.

def provision(package, phase):
    """Start the Colima VM when Colima is the runtime in play.

    Args:
        package: Package metadata and features (read-only, immediate)
        phase: Lifecycle phase context (controls plan, provides metadata)
    """

    plan.choose(
        plan.case(
            when=plan.pkg.installed(name="colima"),
            then=plan.shell.exec(
                command="colima start --cpu 4 --memory 8 --vm-type vz --mount-type virtiofs --vz-rosetta",
            ),
        ),
        default=plan.ui.note(msg="Colima is not the runtime here; the daemon found during install owns itself."),
    )
