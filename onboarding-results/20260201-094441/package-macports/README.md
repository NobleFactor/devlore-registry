# MacPorts

MacPorts is an easy-to-use system for compiling, installing, and upgrading either command-line, X11 or Aqua based open-source software on the Mac operating system. It provides a package management system similar to FreeBSD ports, with over 30,000 ports available.

## Operations

### Deploy
Installs MacPorts using the appropriate .pkg installer for your macOS version, or from source if requested. Automatically configures shell environment and performs initial sync with the MacPorts repository.

### Upgrade
Upgrades MacPorts to a newer version while preserving installed ports. Handles the critical `port migrate` process that's required after major macOS upgrades or architecture changes.

### Decommission
Cleanly removes MacPorts and all installed ports. Provides options for complete removal including configuration files and port registry.

## Features

| Feature | Default | Description |
|---------|---------|-------------|
| `install-from-source` | `false` | Install MacPorts from source instead of using .pkg installer |
| `enable-readline` | `true` | Enable readline support when building from source |
| `auto-accept-xcode-license` | `true` | Automatically accept Xcode license during provisioning |

## Settings

| Setting | Default | Description |
|---------|---------|-------------|
| `macos-version` | `"auto"` | Target macOS version for installer selection |
| `install-prefix` | `"/opt/local"` | Installation prefix (source installations only) |

## Tribal Knowledge

### Binary vs Source Installation Strategy
MacPorts automatically installs from prebuilt binaries when available, falling back to source compilation. Binaries are not available for non-default variants or custom configurations. The .pkg installer is preferred over source installation for most users.
*Reference: Darwin/Deploy/install.star:15-42*

### /usr/local Interference Prevention
Software installed in `/usr/local` or `/Library/Frameworks` can interfere with MacPorts builds, causing mysterious compilation failures. The prepare phase checks for and warns about potential conflicts.
*Reference: Darwin/Deploy/prepare.star:22-35*

### OS Upgrade Migration Requirements
MacPorts installations don't survive major OS upgrades or architecture changes. The migration procedure must be used, or MacPorts must be completely reinstalled. This is handled automatically by the upgrade operation.
*Reference: Darwin/Upgrade/migrate.star:18-67*

### Shell Environment Configuration
`PATH` and optionally `MANPATH` must be configured for MacPorts. The .pkg installer does this automatically via postflight scripts, but source installs require manual configuration.
*Reference: Darwin/Deploy/provision.star:28-45*

### Xcode License Acceptance
For Xcode 4 and later, the license must be accepted either by launching Xcode or running `xcodebuild -license` before MacPorts can use build tools. This is handled automatically during provisioning.
*Reference: Darwin/Deploy/provision.star:52-63*

## Version-Specific Installers

MacPorts provides version-specific .pkg installers for each supported macOS release:
- macOS Tahoe (v26): MacPorts-2.11.6-26-Tahoe.pkg
- macOS Sequoia (v15): MacPorts-2.11.6-15-Sequoia.pkg  
- macOS Sonoma (v14): MacPorts-2.11.6-14-Sonoma.pkg
- macOS Ventura (v13): MacPorts-2.11.6-13-Ventura.pkg

The install phase automatically selects the correct installer based on your macOS version.

## Sources

- [MacPorts Installation Guide](https://www.macports.org/install.php) - Primary installation documentation
- [MacPorts Guide](https://guide.macports.org) - Comprehensive user guide
- [MacPorts FAQ](https://trac.macports.org/wiki/FAQ) - Common issues and solutions
- [MacPorts Migration Guide](https://trac.macports.org/wiki/Migration) - OS upgrade procedures

