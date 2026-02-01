# MacPorts Package Manager

MacPorts is a package management system for macOS that provides an easy-to-use system for compiling, installing, and upgrading command-line, X11, and Aqua-based open-source software. It uses the `/opt/local` prefix to avoid conflicts with system software and other package managers.

## Operations

### Deploy
Fresh installation of MacPorts using version-specific .pkg installers or source compilation. The Deploy operation:
- **prepare**: Checks for Xcode Command Line Tools and removes conflicting software
- **install**: Downloads and installs the appropriate .pkg for your macOS version (REQUIRED)
- **provision**: Sets up PATH and MANPATH in shell configuration files
- **verify**: Runs initial selfupdate and confirms installation

### Upgrade
Upgrades MacPorts to a new version, typically after macOS updates. The Upgrade operation:
- **prepare**: Backs up current configuration and checks system state
- **upgrade**: Installs new MacPorts version (REQUIRED)
- **migrate**: Runs `port migrate` to rebuild installed ports for new system
- **verify**: Confirms upgrade success and port functionality

### Decommission
Completely removes MacPorts from the system. The Decommission operation:
- **unprovision**: Removes PATH modifications from shell configuration
- **uninstall**: Removes all MacPorts software and directories (REQUIRED)
- **cleanup**: Removes any remaining configuration files and groups

## Features

| Feature | Default | Description |
|---------|---------|-------------|
| `install-from-source` | false | Build from source instead of using .pkg installer |
| `install-from-git` | false | Install from Git HEAD instead of release |

## Settings

| Setting | Default | Type | Description |
|---------|---------|------|-----------|
| `macos-version` | "auto" | string | Target macOS version for .pkg selection |
| `prefix` | "/opt/local" | string | Installation prefix (source builds only) |
| `configure-args` | "" | string | Additional configure arguments |

## Tribal Knowledge

### macOS Version-Specific Installers
MacPorts provides version-specific .pkg installers that must match your macOS release. Using the wrong version causes compatibility issues with system libraries and frameworks. The install phase automatically detects your macOS version and selects the appropriate installer.

**Affects**: `Darwin/Deploy/install.star` lines 15-25

### Migration Required for OS Upgrades
MacPorts installations don't survive major macOS upgrades or architecture changes (Intel ↔ Apple Silicon). After upgrading macOS, you must either run the migration procedure or completely reinstall MacPorts. The `port migrate` command (available in MacPorts 2.10.0+) automates rebuilding all installed ports.

**Affects**: `Darwin/Upgrade/migrate.star` lines 10-30

### Xcode Command Line Tools Dependency
Even if Xcode is installed, the Command Line Tools must be separately installed using `xcode-select --install`. This is the #1 cause of MacPorts build failures. The tools provide essential compilers and headers.

**Affects**: `Darwin/Deploy/prepare.star` lines 20-35

### Shell Configuration Auto-Modification
The .pkg installer automatically modifies shell configuration files (`.zprofile`, `.profile`) to set PATH and MANPATH. Source installations require manual shell setup. This ensures MacPorts binaries take precedence over system versions.

**Affects**: `Darwin/Deploy/provision.star` lines 15-40

### Avoid /usr/local Conflicts
MacPorts uses `/opt/local` specifically to avoid conflicts with Homebrew and other software in `/usr/local`. Software in `/usr/local` can interfere with MacPorts builds through unexpected header or library discovery.

**Affects**: `Darwin/Deploy/prepare.star` lines 40-55

## Sources Consulted

- **MacPorts Installation Guide** (https://www.macports.org/install.php) - Primary installation procedures
- **MacPorts Migration Wiki** (https://trac.macports.org/wiki/Migration) - OS upgrade procedures
- **MacPorts FAQ** (https://trac.macports.org/wiki/FAQ) - Common issues and troubleshooting
- **MacPorts Guide** (https://guide.macports.org) - Comprehensive documentation

