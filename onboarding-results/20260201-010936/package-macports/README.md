# MacPorts

An easy to use system for compiling, installing, and managing open source software on macOS. MacPorts uses a ports-based approach where software is built from source with dependency management.

## Key Features

- **Source-based builds**: All software compiled from source for your specific system
- **Dependency management**: Automatic resolution and building of dependencies
- **Version-specific support**: Tailored installers for each macOS version
- **Migration support**: Handle macOS upgrades gracefully
- **Isolation**: Installs to `/opt/local` to avoid system conflicts

## Tribal Knowledge

### OS Upgrade Migration (Darwin/install.star:45-68)

MacPorts installations become incompatible after major macOS upgrades because ports are compiled for the previous OS version. The migration process rebuilds all installed ports for the new OS.

### Xcode License Acceptance (Darwin/prepare.star:15-22)

After installing Xcode 4 or later, the license must be accepted before MacPorts can use development tools. This is a common source of build failures.

### /usr/local Contamination (Darwin/prepare.star:35-42)

Software installed in `/usr/local` or `/Library/Frameworks` can interfere with MacPorts builds, causing mysterious compilation errors. MacPorts uses `/opt/local` specifically to avoid this.

### Version-Specific Installers (Darwin/install.star:25-35)

Each macOS version requires its own MacPorts installer because of differences in system libraries and compiler toolchains. Using the wrong version leads to build failures.

## Features

| Feature | Description | Default |
|---------|-------------|--------|
| `migration` | Migrate ports when upgrading macOS versions | `false` |
| `selfupdate` | Keep MacPorts base and ports tree current | `true` |
| `universal` | Build universal binaries when possible | `false` |

## Settings

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `prefix` | string | `/opt/local` | Installation prefix for MacPorts |
| `rsync_timeout` | integer | `30` | Timeout for rsync operations during selfupdate |
| `build_jobs` | integer | `0` | Number of parallel build jobs (0 = auto) |

## Sources Consulted

- [MacPorts Download & Installation](https://www.macports.org/install.php) - Primary installation guide
- [MacPorts Migration Guide](https://trac.macports.org/wiki/Migration) - OS upgrade procedures
- [MacPorts FAQ](https://trac.macports.org/wiki/FAQ) - Troubleshooting and best practices
- [MacPorts Guide](https://guide.macports.org) - Comprehensive documentation

