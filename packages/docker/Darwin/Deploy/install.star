# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Noble Factor. All rights reserved.
#
# docker/Darwin/Deploy/install.star — Install phase
#
# TRIBAL KNOWLEDGE:
#
# This phase ensures a container runtime exists. It does not install Colima on a machine that
# already has one. Colima is chosen for licensing — Docker Desktop is a paid subscription above 250
# employees or $10M revenue, and OrbStack has a paid commercial tier — so installing Colima
# alongside an existing runtime would add a second VM for no benefit, and displacing a runtime
# somebody deliberately licensed would be worse.
#
# The guard is a decision tree rather than a Starlark conditional because a phase script's runtime
# is hermetic: it cannot interrogate the host at plan time. Every branch is an invocation, never a
# lambda — a lambda is archived as a content-addressed function.Resource, and a graph carrying one
# currently fails receipt writing. Receipts are what decommission compensates from, so a package
# that loses its receipt cannot be removed.
#
# OrbStack and Docker Desktop are applications, so they are detected by path. Colima is a package,
# so it is detected through the package manager, which keeps the check independent of whether the
# router chose MacPorts (/opt/local) or Homebrew (/opt/homebrew).
#
# Reference: https://github.com/abiosoft/colima

def install(package, phase):
    """Ensure a container runtime is present, installing Colima only when none is.

    Args:
        package: Package metadata and features (read-only, immediate)
        phase: Lifecycle phase context (controls plan, provides metadata)
    """

    plan.choose(
        plan.case(
            when=plan.file.is_dir(path="/Applications/OrbStack.app"),
            then=plan.ui.note(msg="OrbStack is present; leaving the container runtime as found."),
        ),
        plan.case(
            when=plan.file.is_dir(path="/Applications/Docker.app"),
            then=plan.ui.note(msg="Docker Desktop is present; leaving the container runtime as found."),
        ),
        plan.case(
            when=plan.pkg.installed(name="colima"),
            then=plan.ui.note(msg="Colima is already installed; nothing to install."),
        ),
        default=plan.pkg.install(packages=["colima", "docker"]),
    )
