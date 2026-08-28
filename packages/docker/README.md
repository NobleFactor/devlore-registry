# docker — a lore package

A container runtime. **Docker CE** on Linux, **Colima** on macOS.

```bash
lore deploy docker
lore upgrade docker
lore decommission docker
lore decommission docker --with purge-data   # also removes images, containers, volumes
```

## Why Colima on macOS

**Licensing, and only licensing.** Docker Desktop requires a paid subscription for organizations
above 250 employees or $10M revenue, and OrbStack has a paid commercial tier. Colima is Apache-2.0
with no threshold. That matters twice over for a package shipped to customers: a Darwin package
built on Docker Desktop hands every customer a licence obligation that scales with their headcount.

Colima is also much easier to automate — a scriptable `colima start` against a DMG mount, an
installer needing `--accept-license`, and a GUI launch. That is a consequence of the choice, not the
reason for it.

## This package ensures a runtime exists; it does not install Colima

Deploy installs Colima **only when no container runtime is present**. An existing OrbStack or Docker
Desktop is left exactly as found — the goal is to avoid putting a licensed product on a machine, not
to displace one somebody chose.

Decommission is asymmetric for the same reason: it removes what deploy installed and nothing else.
That falls out of the receipt boundary rather than needing a feature flag.

## Tribal knowledge

### 1. Binary presence is the wrong check

`command -v docker` is satisfied by a symlink into an application bundle. On a machine with OrbStack
installed, `/usr/local/bin/docker` points into `OrbStack.app`, and a dormant `/Applications/Docker.app`
can sit beside it serving nothing at all.

The question that matters is whether a **daemon answers**, which is what `docker info` asks. Verify
uses it, and it is manager-agnostic and installer-agnostic — it works the same whether the runtime
arrived via MacPorts, Homebrew, the OrbStack installer, or Docker's own `.dmg`.

### 2. The Colima flags are the substance of provisioning

The source script passes only `--cpu 2 --memory 4`, which leaves the VM and mount types at their
defaults:

| Flag | Why |
| --- | --- |
| `--vm-type vz` | Apple's Virtualization.framework rather than QEMU |
| `--mount-type virtiofs` | Closes most of the bind-mount performance gap with Docker Desktop |
| `--vz-rosetta` | Makes x86_64 images tolerable on Apple Silicon |

Without `vz` and `virtiofs`, file sharing falls back to a slower transport — which is the complaint
usually attributed to Colima itself. 4GB is also thin for anything past `hello-world`.

### 3. Colima is not a service

There is no `plan.service.*` on the Darwin path. Colima is a VM manager started in the foreground,
not a launchd service registered under the name `docker`, so the service provider has nothing to
enable.

### 4. The package names no package manager

Both MacPorts and Homebrew carry `colima` and the docker CLI. The package names neither: manager
preference is machine policy, not a property of this package, and the platform router decides.

## Platforms

| Platform | State |
| --- | --- |
| `Darwin` | Deploy implemented |
| `Linux.Debian` | Rewrite pending — Docker CE via apt, with conflict removal and hardware-gated verification |
| `Linux.Fedora` | **Not supported.** The platform router wires no dnf leaf. Driving it through `plan.shell.exec` would work but forfeits receipts, which would defeat decommission-by-compensation |
| `Windows` | Not attempted. `winget` is wired, so it is viable later; no source script covers it |

## Known limitation

`Darwin/Deploy/install.star` detects existing runtimes by path — `/Applications/OrbStack.app` and
`/Applications/Docker.app`. The executing graph is fsroot-confined to its own directory, so those
absolute paths are not reachable and the guard does not yet work as written. The replacement is
`docker info` answering, which is the correct predicate regardless.
