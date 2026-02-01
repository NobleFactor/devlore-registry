# MacPorts

MacPorts is an easy-to-use system for compiling, installing, and upgrading either command-line, X11 or Aqua based open-source software on the Mac OS X operating system. It provides a vast collection of open source software packages compiled for macOS.

## Operations

### Deploy
Fresh installation of MacPorts using version-specific .pkg installers, source compilation, or git checkout. Automatically configures shell environment and performs initial selfupdate.

**Phases:** prepare → install → provision → verify

### Upgrade  
Upgrades MacPorts base and handles OS migration scenarios. After major OS upgrades, this operation rebuilds incompatible ports using the migration system.

**Phases:** prepare → upgrade → migrate → verify

### Decommission
Completely removes MacPorts installation, including all installed ports, the ports tree, and configuration files.

**Phases:** unprovision → uninstall → cleanup

## Features

| Feature | Default | Description |
|---------|---------|-------------|
| `install-from-source` | false | Install from source tarball instead of .pkg installer |
| `install-from-git` | false | Install from git repository (development version) |
| `enable-readline` | true | Enable readline support when building from source |

## Settings

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `prefix` | string | `/opt/local` | Installation prefix (only affects source builds) |
| `macos-version` | string | `auto` | Target macOS version for .pkg installer selection |

## Tribal Knowledge

### Critical Dependencies
MacPorts absolutely requires Apple's Command Line Developer Tools. Many port build failures trace back to missing or outdated CLT. The tools must be installed first and kept current.

**Location:** `Darwin/Deploy/prepare.star:15-28`

### Version-Specific Installers
MacPorts provides different .pkg installers for each macOS version. Using the wrong installer causes compatibility issues and silent failures. The installer selection logic automatically detects the OS version.

**Location:** `Darwin/Deploy/install.star:35-52`

### OS Migration Required
Major macOS upgrades break binary compatibility for installed ports. MacPorts 2.10.0+ includes a migration system that automatically rebuilds incompatible ports. This is not optional - it's required maintenance.

**Location:** `Darwin/Upgrade/migrate.star:25-45`

### Xcode License Acceptance
Xcode 4 and later require accepting the End User License Agreement via `xcodebuild -license` before ports can build successfully. This is a common source of cryptic build failures.

**Location:** `Darwin/Deploy/prepare.star:30-38`

### Shell Environment Setup
The .pkg installer automatically configures shell PATH and MANPATH, but source installs require manual configuration. A new terminal session is required for changes to take effect.

**Location:** `Darwin/Deploy/provision.star:28-42`

### Architecture Mismatch Detection
The infamous "libiconv version error" usually indicates architecture mismatches after OS migrations. The prepare phase now detects and warns about this condition.

**Location:** `Darwin/Upgrade/prepare.star:45-58`

## Sources Consulted

- **MacPorts Download & Installation**: Official installation guide with quickstart and detailed procedures
- **MacPorts Migration Guide**: Procedures for handling OS upgrades and architecture changes  
- **MacPorts Guide**: Comprehensive documentation covering all installation methods
- **MacPorts Problem Hotlist**: Common issues and troubleshooting procedures

## Dependencies

- **xcode-command-line-tools** (required): Essential for building ports from source
- **xcode** (optional): Required for some ports, version requirements vary by macOS version
- **x11** (optional): XQuartz or xorg-server port for GUI applications

## Conflicts

- **homebrew**: Different installation prefixes can cause library conflicts (warning level)

MacPorts installs to `/opt/local` while Homebrew uses `/usr/local` (Intel) or `/opt/homebrew` (Apple Silicon). While they can coexist, PATH ordering determines precedence and may cause unexpected behavior.
