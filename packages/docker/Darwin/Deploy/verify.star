# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Noble Factor. All rights reserved.
#
# docker/Darwin/Deploy/verify.star — Verify phase
#
# TRIBAL KNOWLEDGE:
#
# Binary presence is the wrong check. On a machine carrying OrbStack, `docker` resolves to
# /usr/local/bin/docker, a symlink into OrbStack.app — and a dormant /Applications/Docker.app can
# sit alongside it serving nothing. What matters is whether a daemon answers, which is what
# `docker info` asks and `command -v docker` does not.
#
# hello-world is the canonical smoke test and is what Install-Docker and Install-Dependencies both
# finish with. It proves the daemon can pull, create, and run — which `docker info` alone does not.
#
# There is no plan.verify builtin. Verification is ordinary graph work, plus the declarative
# verification block in lifecycle.yaml that supplies the receipt's verify status.

def verify(package, phase):
    """Confirm a container daemon answers and can run a container.

    Args:
        package: Package metadata and features (read-only, immediate)
        phase: Lifecycle phase context (controls plan, provides metadata)
    """

    plan.shell.exec(command="docker info")
    plan.shell.exec(command="docker run --rm hello-world")
