# Docker Package Lifecycle Example

This directory contains a fully worked example of a lore package-lifecycle-manifest using Starlark phase scripts.

## Usage

```bash
# Deploy docker
lore deploy docker

# Deploy with features
lore deploy docker --with rootless

# Reconcile: compare receipt vs actual system state
lore reconcile @docker.receipt
```

## Files

| File | Purpose |
|------|---------|
| `lifecycle.yaml` | Package lifecycle manifest: conflicts, packages, hardware provisions, pipelines |
| `prepare.star` | Phase 1: Remove conflicts, update package lists |
| `install.star` | Phase 2: Install docker packages via apt |
| `provision.star` | Phase 3: Hardware config, add user to docker group |
| `verify.star` | Phase 4: Confirm installation, generate pipeline-receipt |

## Deploy Pipeline Flow

```mermaid
flowchart TB
    subgraph input
        manifest[package-manifest]
    end

    subgraph deploy[Deploy Pipeline]
        prepare[prepare.star]
        install[install.star]
        provision[provision.star]
        verify[verify.star]
        prepare --> install --> provision --> verify
    end

    subgraph output
        receipt[pipeline-receipt]
    end

    manifest --> deploy
    verify --> receipt

    subgraph reconcile[Reconcile Pipeline]
        compare[Compare receipt vs actual]
        delta[Report delta/drift]
        compare --> delta
    end

    receipt -.-> reconcile
```

## Phase Details

```mermaid
flowchart TB
    subgraph prepare.star
        P1[Check platform - Linux only]
        P2[Remove conflicts: docker.io, podman-docker, containerd, runc]
        P3[apt-get autoremove]
        P4[apt-get update]
        P1 --> P2 --> P3 --> P4
    end

    subgraph install.star
        I1[apt-get install docker-ce docker-ce-cli containerd.io]
        I2[Install docker-buildx-plugin docker-compose-plugin]
        I1 --> I2
    end

    subgraph provision.star
        V1[Detect hardware - lshw -json]
        V2[ODROID-C4/C5: Check boot.ini for cgroup fix]
        V3[Add user to docker group]
        V1 --> V2 --> V3
    end

    subgraph verify.star
        Y1[Check docker command exists]
        Y2[Check daemon running - docker info]
        Y3[Run hello-world container]
        Y4[Generate pipeline-receipt]
        Y1 --> Y2 --> Y3 --> Y4
    end

    prepare.star --> install.star --> provision.star --> verify.star
```

## Phase Contract

```python
def main(lifecycle, state, features, settings):
    """
    Args:
        lifecycle: Package lifecycle manifest from YAML (dict)
        state:     Output from previous phase (dict)
        features:  List of enabled features (e.g., ["rootless"])
        settings:  Dict of settings (e.g., {"storage-driver": "overlay2"})

    Returns:
        dict: State passed to next phase (becomes part of pipeline-receipt)

    Logging API:
        note(msg)           - Informational, continues execution
        warn(msg)           - Warning, continues execution
        error(msg)          - Fails phase, triggers rollback
        success(msg, state) - Exits phase successfully (early exit)
    """
```

## Platform Object

Available in all phases as `platform`:

```python
platform.os      # "darwin", "linux", "windows" (GOOS)
platform.arch    # "amd64", "arm64" (GOARCH)
platform.distro  # "macos", "ubuntu", "debian", "fedora", etc.
```

## Data Artifacts

| Artifact | Description |
|----------|-------------|
| `docker --with rootless` | package-spec: single package with features |
| `@workstation.manifest` | package-manifest: list of package-specs |
| `workstation.receipt` | pipeline-receipt: post-deploy state, enables reconcile |
| `docker/lifecycle.yaml` | package-lifecycle-manifest: defines deploy/upgrade/decommission |

## Tribal Knowledge Captured

This package captures knowledge that would otherwise be tribal:

1. **Conflicting packages** - docker.io, podman-docker, containerd, runc must be removed first
2. **ODROID cgroup fix** - C4/C5 boards need `systemd.unified_cgroup_hierarchy=0` in boot.ini
3. **User group membership** - Add user to docker group to avoid sudo requirement
4. **Post-install verification** - Run hello-world to confirm working installation
