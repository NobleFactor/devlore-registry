# devlore Registry

Official package registry for [lore](https://github.com/NobleFactor/noblefactor) — lifecycle manifests encoding tribal knowledge.

Each package encodes installation knowledge that would otherwise require hours of debugging, Stack Overflow searches, and trial-and-error. The goal: install once, document forever.

## Package Index

| Package | Platforms | Description | Key Tribal Knowledge |
|---------|-----------|-------------|---------------------|
| [astro](packages/astro/) | all | Web framework for content-driven sites | Node.js version matrix, npm permission fixes |
| [aws-cli](packages/aws-cli/) | all | AWS Command Line Interface v2 | v1/v2 conflicts, Session Manager plugin |
| [azure-cli](packages/azure-cli/) | all | Azure Command Line Interface | Extension management, login flows |
| [docker](packages/docker/) | Linux | Docker CE with containerd | Conflict removal, rootless mode, cgroup fixes |
| [gcloud](packages/gcloud/) | all | Google Cloud CLI | Component installation, auth configurations |
| [kubectl](packages/kubectl/) | all | Kubernetes command-line tool | Plugin ecosystem (krew), auth plugins per cloud |
| [pandoc](packages/pandoc/) | all | Universal document converter | PDF engines, LaTeX package hell, tlmgr |
| [terraform](packages/terraform/) | all | Infrastructure as Code | Version pinning, provider caching, tflint |
| [xcode](packages/xcode/) | Darwin | Xcode IDE | Version pinning, simulator management, provisioning |
| [xcode-clt](packages/xcode-clt/) | Darwin | Xcode Command Line Tools | Headless installation, license acceptance |

## Package Documentation Format

Each package directory contains:

```
<package>/
├── README.md           # Tribal knowledge, usage, features, settings
├── lifecycle.yaml      # Package metadata and phase declarations
├── prepare.star        # Phase 1: Validate preconditions, remove conflicts
├── install.star        # Phase 2: Acquire and install software
├── provision.star      # Phase 3: Configure for use
└── verify.star         # Phase 4: Confirm working installation
```

## README Standard Format

Package READMEs follow this structure:

1. **Title & Description** — What the package installs
2. **Tribal Knowledge** — The hard-won insights this package encodes (most important section)
3. **Usage** — Command examples with features and settings
4. **Features** — Optional capabilities table
5. **Settings** — Configuration options table
6. **Files** — Package contents table
7. **Sources** — External references consulted

## What Makes Good Tribal Knowledge Documentation

Tribal knowledge is the "invisible dependency" problem — things you only learn through painful experience:

- **Conflicts**: Packages that must be removed first (docker.io vs docker-ce)
- **Hidden dependencies**: Things the docs don't mention (pandoc needs tlmgr packages for PDF)
- **Platform quirks**: OS-specific gotchas (ODROID cgroup fixes, macOS license acceptance)
- **Version matrices**: Which versions work together (Node.js + Astro compatibility)
- **Authentication plugins**: Cloud-specific auth tools (kubelogin, aws-iam-authenticator)
- **Post-install steps**: What the installer doesn't do (add user to docker group)

Good documentation answers: "What would I wish someone had told me before I started?"

## Adding a New Package

For AI-assisted authoring, use the trigger phrase:

> **"give me a package manifest for `<product-name>`"**

See [AUTHORING.md](AUTHORING.md) for complete instructions.

### Manual Steps

1. Create directory: `packages/<package>/`
2. Write `lifecycle.yaml` with metadata, features, settings
3. Implement four phase scripts (prepare, install, provision, verify)
4. Document tribal knowledge in `README.md`
5. Test on target platforms

See [astro](packages/astro/) for a cross-platform example, [xcode-clt](packages/xcode-clt/) for a platform-specific example.

## Related Documentation

- [noblefactor](https://github.com/NobleFactor/noblefactor) — Main lore repository with design docs and ADRs
- [ADR-018: Package Registry Layout](https://github.com/NobleFactor/noblefactor/blob/main/lore/design/adr/018-package-registry-layout.md) — Registry structure decisions
