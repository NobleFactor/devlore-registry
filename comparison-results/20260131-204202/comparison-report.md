# Migration Provider Comparison

**Source:** /Users/david-noble/Workspace/Personal
**Date:** 2026-02-01 04:43:53 UTC
**Providers:** gemini

## Summary

| Provider | Duration | Output Size | Valid JSON |
|----------|----------|-------------|------------|
| gemini | 110s | 37696 bytes | ❌ No |

## Outputs

### gemini

```json
```json
{
  "source_system": "tuckr",
  "repo_layer": "personal",
  "source_location": "/Users/david-noble/Workspace/Personal",
  "target_location": "~/dotfiles",
  "projects": [
    {
      "name": "all",
      "description": "Core configs deployed everywhere",
      "source_groups": ["all"],
      "always_deploy": true
    },
    {
      "name": "microsoft",
      "description": "Configuration for microsoft",
      "source_groups": ["microsoft"],
      "always_deploy": false
    },
    {
      "name": "noblefactor",
      "description": "Configuration for noblefactor",
      "source_groups": ["noblefactor"],
      "always_deploy": false
    },
    {
      "name": "thenobles",
      "description": "Configuration for thenobles",
      "source_groups": ["thenobles"],
      "always_deploy": false
    }
  ],
  "segments": [
    {
      "directory": "all.Darwin",
      "condition": "Darwin",
      "source_equivalent": "all-Darwin"
    },
    {
      "directory": "all.Debian",
      "condition": "Debian",
      "source_equivalent": "all-Debian"
    },
    {
      "directory": "all.Linux",
      "condition": "Linux",
      "source_equivalent": "all-Linux"
    },
    {
      "directory": "all.Unix",
      "condition": "Unix",
      "source_equivalent": "all-Unix"
    },
    {
      "directory": "all.Windows",
      "condition": "Windows",
      "source_equivalent": "all-Windows"
    },
    {
      "directory": "microsoft.Unix",
      "condition": "Unix",
      "source_equivalent": "microsoft-Unix"
    },
    {
      "directory": "microsoft.Windows",
      "condition": "Windows",
      "source_equivalent": "microsoft-Windows"
    },
    {
      "directory": "noblefactor.Unix",
      "condition": "Unix",
      "source_equivalent": "noblefactor-Unix"
    },
    {
      "directory": "thenobles.Darwin",
      "condition": "Darwin",
      "source_equivalent": "thenobles-Darwin"
    },
    {
      "directory": "System/Darwin",
      "condition": "Darwin",
      "source_equivalent": "Tools/Darwin"
    },
    {
      "directory": "System/Debian",
      "condition": "Debian",
      "source_equivalent": "Tools/Debian"
    },
    {
      "directory": "System/RHEL",
      "condition": "RHEL",
      "source_equivalent": "Tools/RHEL"
    },
    {
      "directory": "System/Windows",
      "condition": "Windows",
      "source_equivalent": "Tools/Windows"
    }
  ],
  "template_conversions": [],
  "encryption_conversions": [
    {
      "source_path": "Home/Configs/all/.ssh/config",
      "target_path": "Home/all/.ssh/config.age",
      "source_method": "git-crypt",
      "target_method": "age"
    },
    {
      "source_path": "Home/Configs/all/.ssh/id_rsa",
      "target_path": "Home/all/.ssh/id_rsa.age",
      "source_method": "git-crypt",
      "target_method": "age"
    },
    {
      "source_path": "Home/Configs/all/.Personal-secrets/gnupg/gpg-secret-keys.asc",
      "target_path": "Home/all/.Personal-secrets/gnupg/gpg-secret-keys.asc.age",
      "source_method": "git-crypt",
      "target_method": "age"
    },
    {
      "source_path": "Home/Configs/all-Unix/.Personal-secrets/gnupg/gpg-secret-keys.asc",
      "target_path": "Home/all.Unix/.Personal-secrets/gnupg/gpg-secret-keys.asc.age",
      "source_method": "git-crypt",
      "target_method": "age"
    }
  ],
  "unencrypted_secrets": [
    {
      "path": "Deployments/homebridge/US-WA/certificate-request.env",
      "reason": "Filename matches '.env'",
      "recommendation": "Encrypt with .age or .sops extension",
      "severity": "high"
    },
    {
      "path": "Deployments/homebridge/US-WA/ssl/private-key.pem",
      "reason": "Filename matches '*.pem'",
      "recommendation": "Encrypt with .age or .sops extension",
      "severity": "critical"
    },
    {
      "path": "Deployments/webhook/us-wa/certificate-request.env",
      "reason": "Filename matches '.env'",
      "recommendation": "Encrypt with .age or .sops extension",
      "severity": "high"
    },
    {
      "path": "Deployments/webhook/us-wa/hooks.env",
      "reason": "Filename matches '.env'",
      "recommendation": "Encrypt with .age or .sops extension",
      "severity": "high"
    },
    {
      "path": "Deployments/webhook/us-wa/service.env",
      "reason": "Filename matches '.env'",
      "recommendation": "Encrypt with .age or .sops extension",
      "severity": "high"
    },
    {
      "path": "Deployments/webhook/us-wa/ssh/id_rsa",
      "reason": "Filename matches 'id_rsa'",
      "recommendation": "Encrypt with .age or .sops extension",
      "severity": "critical"
    },
    {
      "path": "Deployments/webhook/us-wa/ssl-certificates/private-key.pem",
      "reason": "Filename matches '*.pem'",
      "recommendation": "Encrypt with .age or .sops extension",
      "severity": "critical"
    }
  ],
  "script_conversions": [
    {
      "source_path": "Build-DarwinInitializationPackage",
      "packages_extracted": [
        "port:cargo",
        "port:pre-commit",
        "cargo:tuckr",
        "brew:git",
        "brew:git-credential-oauth",
        "brew:git-crypt",
        "brew:gnupg",
        "brew:jq",
        "brew:mosh",
        "brew:nmap",
        "brew:openssh",
        "brew:rclone",
        "brew:tmux",
        "brew:tree",
        "brew:vim",
        "brew:claude",
        "brew:powershell",
        "brew:.net sdk"
      ],
      "non_package_commands": []
    },
    {
      "source_path": "Build-DebianInitializationPackage",
      "packages_extracted": [
        "apt:dirmngr",
        "apt:aptitude",
        "apt:apt-transport-https",
        "apt:ca-certificates",
        "apt:gnupg",
        "apt:wget",
        "apt:zsh",
        "apt:apparmor-utils",
        "apt:bash-completion",
        "apt:curl",
        "apt:expect",
        "apt:gh",
        "apt:git",
        "apt:git-credential-oauth",
        "apt:git-crypt",
        "apt:jq",
        "apt:mosh",
        "apt:nmap",
        "apt:openssh-server",
        "apt:pre-commit",
        "apt:rclone",
        "apt:shellcheck",
        "apt:shfmt",
        "apt:tmux",
        "apt:tree",
        "apt:vim",
        "apt:code",
        "apt:meld",
        "apt:xrdp",
        "pip:pre-commit",
        "cargo:tuckr"
      ],
      "non_package_commands": []
    },
    {
      "source_path": "Build-RHELInitializationPackage",
      "packages_extracted": [
        "dnf:ca-certificates",
        "dnf:gnupg",
        "dnf:wget",
        "dnf:zsh",
        "dnf:bash-completion",
        "dnf:curl",
        "dnf:expect",
        "dnf:gh",
        "dnf:git",
        "dnf:git-credential-oauth",
        "dnf:git-crypt",
        "dnf:jq",
        "dnf:mosh",
        "dnf:nmap",
        "dnf:openssh-server",
        "dnf:pre-commit",
        "dnf:rclone",
        "dnf:shellcheck",
        "dnf:shfmt",
        "dnf:tmux",
        "dnf:tree",
        "dnf:vim-enhanced",
        "dnf:wget",
        "dnf:zsh",
        "dnf:code",
        "dnf:meld",
        "dnf:xrdp",
        "pip:pre-commit",
        "cargo:tuckr"
      ],
      "non_package_commands": []
    },
    {
      "source_path": "Build-WindowsInitializationPackage",
      "packages_extracted": [
        "winget:Git.Git",
        "winget:GnuPG.GnuPG",
        "winget:Azul.Zulu.25.JDK",
        "winget:GitHub.cli",
        "winget:GoLang.Go",
        "winget:Insecure.Nmap",
        "winget:JetBrains.Toolbox",
        "winget:Microsoft.AzureCLI",
        "winget:Microsoft.DotNet.SDK.10",
        "winget:Microsoft.VisualStudioCode",
        "winget:OpenJS.NodeJS.LTS",
        "winget:PostgreSQL.PostgreSQL.17",
        "winget:Python.Python.3.14",
        "winget:Rclone.Rclone",
        "winget:Rustlang.Rustup",
        "winget:vim.vim",
        "cargo:tuckr",
        "pip:pre-commit"
      ],
      "non_package_commands": []
    },
    {
      "source_path": "Home/Configs/microsoft-Windows/Deploy-CosmosDB.ps1",
      "packages_extracted": [],
      "non_package_commands": [
        "net use \\\\cd3\\drop",
        ".\\x64\\Release\\RDTools\\Scripts\\CreateVSRMReleaseEV2.ps1"
      ]
    },
    {
      "source_path": "Install-UnixUserConfiguration",
      "packages_extracted": [
        "cargo:tuckr"
      ],
      "non_package_commands": [
        "Remove-BrokenLinks",
        "zcompile -Uz ~/.functions.zwc",
        "git config --global user.name",
        "git config --global user.email",
        "dscl . -read \"/Users/${SUDO_USER:-$USER}\" RealName",
        "getent passwd \"${SUDO_USER:-$USER}\"",
        "git config --file ~/.config/git/config --add include.path",
        "~/local/bin/Initialize-SshIdentity",
        "cat ~/.ssh/authorized_keys.d/*(N) > ~/.ssh/authorized_keys",
        "~/local/bin/Complete-TuckrSetup"
      ]
    },
    {
      "source_path": "Install-WindowsUserConfiguration.ps1",
      "packages_extracted": [
        "cargo:tuckr",
        "pip:pre-commit"
      ],
      "non_package_commands": [
        "Remove-BrokenLinks",
        "New-Item -ItemType Directory -Path (Join-Path $powerShellPath 'Modules')",
        "New-Item -ItemType SymbolicLink -Path $windowsPowerShellPath -Target $powerShellPath",
        "git config --global user.name",
        "git config --global user.email",
        "net user $env:USERNAME",
        "git config --file $gitConfigPath --add include.path",
        "git config --file $gitConfigLocalPath core.editor",
        "Add-Content -Path $sshConfigPath -Value 'Include ./config.d/*'",
        "Get-ChildItem -Path $authorizedKeysDir -File",
        "& $fixUpAclsScript",
        "& $completeTuckrSetup"
      ]
    },
    {
      "source_path": "Tools/Darwin/Initialize-Darwin",
      "packages_extracted": [
        "port:cargo",
        "port:pre-commit",
        "cargo:tuckr",
        "brew:git",
        "brew:git-credential-oauth",
        "brew:git-crypt",
        "brew:gnupg",
        "brew:jq",
        "brew:mosh",
        "brew:nmap",
        "brew:openssh",
        "brew:rclone",
        "brew:tmux",
        "brew:tree",
        "brew:vim"
      ],
      "non_package_commands": [
        "Install Command Line Tools",
        "Install MacPorts",
        "Install Homebrew",
        "Update /etc",
        "Setup home directory with contents from Personal GitHub repository"
      ]
    },
    {
      "source_path": "Tools/Debian/Initialize-Debian",
      "packages_extracted": [
        "apt:dirmngr",
        "apt:aptitude",
        "apt:apt-transport-https",
        "apt:ca-certificates",
        "apt:gnupg",
        "apt:wget",
        "apt:zsh",
        "apt:apparmor-utils",
        "apt:bash-completion",
        "apt:curl",
        "apt:expect",
        "apt:gh",
        "apt:git",
        "apt:git-credential-oauth",
        "apt:git-crypt",
        "apt:jq",
        "apt:mosh",
        "apt:nmap",
        "apt:openssh-server",
        "apt:pre-commit",
        "apt:rclone",
        "apt:shellcheck",
        "apt:shfmt",
        "apt:tmux",
        "apt:tree",
        "apt:vim",
        "apt:code",
        "apt:meld",
        "apt:xrdp",
        "pip:pre-commit",
        "cargo:tuckr"
      ],
      "non_package_commands": [
        "dpkg-reconfigure --frontend=noninteractive locales",
        "update-alternatives --set pinentry",
        "Update system environment",
        "Add third-party repositories",
        "Install Claude Code CLI",
        "Install Git Credential Manager",
        "Install Tuckr",
        "Install .NET SDK",
        "Install personal environment",
        "Tweak system configuration",
        "Install graphical development tools"
      ]
    },
    {
      "source_path": "Tools/RHEL/Initialize-RHEL",
      "packages_extracted": [
        "dnf:ca-certificates",
        "dnf:gnupg",
        "dnf:wget",
        "dnf:zsh",
        "dnf:bash-completion",
        "dnf:curl",
        "dnf:expect",
        "dnf:gh",
        "dnf:git",
        "dnf:git-credential-oauth",
        "dnf:git-crypt",
        "dnf:jq",
        "dnf:mosh",
        "dnf:nmap",
        "dnf:openssh-server",
        "dnf:pre-commit",
        "dnf:rclone",
        "dnf:shellcheck",
        "dnf:shfmt",
        "dnf:tmux",
        "dnf:tree",
        "dnf:vim-enhanced",
        "dnf:wget",
        "dnf:zsh",
        "dnf:code",
        "dnf:meld",
        "dnf:xrdp",
        "pip:pre-commit",
        "cargo:tuckr"
      ],
      "non_package_commands": [
        "dnf clean all && dnf makecache",
        "dnf upgrade --assumeyes --refresh",
        "update-alternatives --set pinentry",
        "Update system environment",
        "Add third-party repositories",
        "Install Claude Code CLI",
        "Install Git Credential Manager",
        "Install Tuckr",
        "Install .NET SDK",
        "Install personal environment",
        "Set system account info",
        "Install user configuration",
        "Install graphical development tools"
      ]
    },
    {
      "source_path": "Tools/Windows/FixUp-Acls.ps1",
      "packages_extracted": [],
      "non_package_commands": [
        "Set-Acl",
        "Get-Acl",
        "SetAccessRuleProtection",
        "RemoveAccessRule",
        "SetAccessRule"
      ]
    },
    {
      "source_path": "Tools/Windows/FixUp-Path.ps1",
      "packages_extracted": [],
      "non_package_commands": [
        "Set-EnvironmentVariable('Path')"
      ]
    },
    {
      "source_path": "Tools/Windows/Initialize-OpenSsh.ps1",
      "packages_extracted": [],
      "non_package_commands": [
        "Add-WindowsCapability -Online -Name OpenSSH.Client",
        "Add-WindowsCapability -Online -Name OpenSSH.Server",
        "Copy-Item ~\\.ssh\\authorized_keys $env:ProgramData\\ssh\\administrators_authorized_keys",
        "Set-Acl",
        "New-ItemProperty -Path \"HKLM:\\SOFTWARE\\OpenSSH\" -Name DefaultShell",
        "Set-Service -Name ssh-agent -StartupType AutomaticDelayedStart",
        "Set-Service -Name sshd -StartupType Automatic",
        "Restart-Service -Force ssh-agent, sshd",
        "Set-Content -Path \"$env:ProgramData\\ssh\\sshd_config\""
      ]
    },
    {
      "source_path": "Tools/Windows/Initialize-Windows.ps1",
      "packages_extracted": [
        "winget:Git.Git",
        "winget:GnuPG.GnuPG",
        "winget:Azul.Zulu.25.JDK",
        "winget:GitHub.cli",
        "winget:GoLang.Go",
        "winget:Insecure.Nmap",
        "winget:JetBrains.Toolbox",
        "winget:Microsoft.AzureCLI",
        "winget:Microsoft.DotNet.SDK.10",
        "winget:Microsoft.VisualStudioCode",
        "winget:OpenJS.NodeJS.LTS",
        "winget:PostgreSQL.PostgreSQL.17",
        "winget:Python.Python.3.14",
        "winget:Rclone.Rclone",
        "winget:Rustlang.Rustup",
        "winget:vim.vim",
        "cargo:tuckr",
        "pip:pre-commit"
      ],
      "non_package_commands": [
        "Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force",
        "Set-PSRepository -Name PSGallery -InstallationPolicy Trusted",
        "New-Item -ItemType Directory -Path $workspaceDir -Force",
        "winget source update",
        "Import GPG keys",
        "Install Apache Maven",
        "Install WSL2 with Ubuntu",
        "Install git-crypt",
        "Install PowerShell modules",
        "Configure OpenSSH",
        "Enable long paths",
        "Enable Developer Mode",
        "Clone or update Personal repository",
        "Unlock git-crypt",
        "Install pre-commit hooks",
        "Add local\\bin and .local\\bin to user PATH",
        "Run install script",
        "Secure directories",
        "Fixing up PATH variables"
      ]
    },
    {
      "source_path": "Tools/Windows/Install-ApacheMaven.ps1",
      "packages_extracted": [],
      "non_package_commands": [
        "Invoke-WebRequest",
        "Expand-Archive",
        "Move-Item",
        "Set-EnvironmentVariable('Path')"
      ]
    },
    {
      "source_path": ".Personal-secrets/gnupg/Import-GnuPg.ps1",
      "packages_extracted": [],
      "non_package_commands": [
        "gpg --allow-secret-key-import --import gpg-secret-keys.asc",
        "gpg --import gpg-public-keys.asc",
        "gpg --import-ownertrust gpg-owner-trust.txt"
      ]
    }
  ],
  "execution_graph": {
    "nodes": [
      {
        "id": "mkdir-001",
        "op": "mkdir",
        "target": ".",
        "reason": "Create writ source root"
      },
      {
        "id": "mkdir-002",
        "op": "mkdir",
        "target": "Home",
        "reason": "Create Home directory for user configs"
      },
      {
        "id": "mkdir-003",
        "op": "mkdir",
        "target": "System",
        "reason": "Create System directory for system configs"
      },
      {
        "id": "rename-004",
        "op": "rename",
        "source": "Home/Configs/all",
        "target": "Home/all",
        "project": "all",
        "reason": "Restructure Home/Configs/all to writ format"
      },
      {
        "id": "rename-005",
        "op": "rename",
        "source": "Home/Configs/all-Darwin",
        "target": "Home/all.Darwin",
        "project": "all",
        "reason": "Restructure Home/Configs/all-Darwin to writ format"
      },
      {
        "id": "rename-006",
        "op": "rename",
        "source": "Home/Configs/all-Debian",
        "target": "Home/all.Debian",
        "project": "all",
        "reason": "Restructure Home/Configs/all-Debian to writ format"
      },
      {
        "id": "rename-007",
        "op": "rename",
        "source": "Home/Configs/all-Linux",
        "target": "Home/all.Linux",
        "project": "all",
        "reason": "Restructure Home/Configs/all-Linux to writ format"
      },
      {
        "id": "rename-008",
        "op": "rename",
        "source": "Home/Configs/all-Unix",
        "target": "Home/all.Unix",
        "project": "all",
        "reason": "Restructure Home/Configs/all-Unix to writ format"
      },
      {
        "id": "rename-009",
        "op": "rename",
        "source": "Home/Configs/all-Windows",
        "target": "Home/all.Windows",
        "project": "all",
        "reason": "Restructure Home/Configs/all-Windows to writ format"
      },
      {
        "id": "rename-010",
        "op": "rename",
        "source": "Home/Configs/microsoft",
        "target": "Home/microsoft",
        "project": "microsoft",
        "reason": "Restructure Home/Configs/microsoft to writ format"
      },
      {
        "id": "rename-011",
        "op": "rename",
        "source": "Home/Configs/microsoft-Unix",
        "target": "Home/microsoft.Unix",
        "project": "microsoft",
        "reason": "Restructure Home/Configs/microsoft-Unix to writ format"
      },
      {
        "id": "rename-012",
        "op": "rename",
        "source": "Home/Configs/microsoft-Windows",
        "target": "Home/microsoft.Windows",
        "project": "microsoft",
        "reason": "Restructure Home/Configs/microsoft-Windows to writ format"
      },
      {
        "id": "rename-013",
        "op": "rename",
        "source": "Home/Configs/noblefactor",
        "target": "Home/noblefactor",
        "project": "noblefactor",
        "reason": "Restructure Home/Configs/noblefactor to writ format"
      },
      {
        "id": "rename-014",
        "op": "rename",
        "source": "Home/Configs/noblefactor-Unix",
        "target": "Home/noblefactor.Unix",
        "project": "noblefactor",
        "reason": "Restructure Home/Configs/noblefactor-Unix to writ format"
      },
      {
        "id": "rename-015",
        "op": "rename",
        "source": "Home/Configs/thenobles",
        "target": "Home/thenobles",
        "project": "thenobles",
        "reason": "Restructure Home/Configs/thenobles to writ format"
      },
      {
        "id": "rename-016",
        "op": "rename",
        "source": "Home/Configs/thenobles-Darwin",
        "target": "Home/thenobles.Darwin",
        "project": "thenobles",
        "reason": "Restructure Home/Configs/thenobles-Darwin to writ format"
      },
      {
        "id": "rename-017",
        "op": "rename",
        "source": "Tools/Darwin",
        "target": "System/Darwin",
        "reason": "Restructure Tools/Darwin to writ format"
      },
      {
        "id": "rename-018",
        "op": "rename",
        "source": "Tools/Debian",
        "target": "System/Debian",
        "reason": "Restructure Tools/Debian to writ format"
      },
      {
        "id": "rename-019",
        "op": "rename",
        "source": "Tools/RHEL",
        "target": "System/RHEL",
        "reason": "Restructure Tools/RHEL to writ format"
      },
      {
        "id": "rename-020",
        "op": "rename",
        "source": "Tools/Windows",
        "target": "System/Windows",
        "reason": "Restructure Tools/Windows to writ format"
      },
      {
        "id": "decrypt-021",
        "op": "decrypt",
        "source": "Home/Configs/all/.ssh/config",
        "target": "Home/all/.ssh/config.age",
        "reason": "Decrypt from git-crypt and re-encrypt to age"
      },
      {
        "id": "remove-022",
        "op": "remove",
        "source": "Home/Configs/all/.ssh/config",
        "reason": "Remove original git-crypt encrypted file after re-encryption"
      },
      {
        "id": "decrypt-023",
        "op": "decrypt",
        "source": "Home/Configs/all/.ssh/id_rsa",
        "target": "Home/all/.ssh/id_rsa.age",
        "reason": "Decrypt from git-crypt and re-encrypt to age"
      },
      {
        "id": "remove-024",
        "op": "remove",
        "source": "Home/Configs/all/.ssh/id_rsa",
        "reason": "Remove original git-crypt encrypted file after re-encryption"
      },
      {
        "id": "decrypt-025",
        "op": "decrypt",
        "source": "Home/Configs/all/.Personal-secrets/gnupg/gpg-secret-keys.asc",
        "target": "Home/all/.Personal-secrets/gnupg/gpg-secret-keys.asc.age",
        "reason": "Decrypt from git-crypt and re-encrypt to age"
      },
      {
        "id": "remove-026",
        "op": "remove",
        "source": "Home/Configs/all/.Personal-secrets/gnupg/gpg-secret-keys.asc",
        "reason": "Remove original git-crypt encrypted file after re-encryption"
      },
      {
        "id": "decrypt-027",
        "op": "decrypt",
        "source": "Home/Configs/all-Unix/.Personal-secrets/gnupg/gpg-secret-keys.asc",
        "target": "Home/all.Unix/.Personal-secrets/gnupg/gpg-secret-keys.asc.age",
        "reason": "Decrypt from git-crypt and re-encrypt to age"
      },
      {
        "id": "remove-028",
        "op": "remove",
        "source": "Home/Configs/all-Unix/.Personal-secrets/gnupg/gpg-secret-keys.asc",
        "reason": "Remove original git-crypt encrypted file after re-encryption"
      },
      {
        "id": "generate-029",
        "op": "generate",
        "target": "Home/all/packages.manifest",
        "project": "all",
        "reason": "Generate packages.manifest from extracted package installs"
      },
      {
        "id": "generate-030",
        "op": "generate",
        "target": "System/Darwin/lifecycle.yaml",
        "project": null,
        "reason": "Convert script logic from Tools/Darwin/Initialize-Darwin to lifecycle.yaml"
      },
      {
        "id": "generate-031",
        "op": "generate",
        "target": "System/Darwin/packages.manifest",
        "project": null,
        "reason": "Generate packages.manifest from extracted package installs"
      },
      {
        "id": "generate-032",
        "op": "generate",
        "target": "System/Debian/lifecycle.yaml",
        "project": null,
        "reason": "Convert script logic from Tools/Debian/Initialize-Debian to lifecycle.yaml"
      },
      {
        "id": "generate-033",
        "op": "generate",
        "target": "System/Debian/packages.manifest",
        "project": null,
        "reason": "Generate packages.manifest from extracted package installs"
      },
      {
        "id": "generate-034",
        "op": "generate",
        "target": "System/RHEL/lifecycle.yaml",
        "project": null,
        "reason": "Convert script logic from Tools/RHEL/Initialize-RHEL to lifecycle.yaml"
      },
      {
        "id": "generate-035",
        "op": "generate",
        "target": "System/RHEL/packages.manifest",
        "project": null,
        "reason": "Generate packages.manifest from extracted package installs"
      },
      {
        "id": "generate-036",
        "op": "generate",
        "target": "System/Windows/lifecycle.yaml",
        "project": null,
        "reason": "Convert script logic from Tools/Windows/Initialize-Windows.ps1 to lifecycle.yaml"
      },
      {
        "id": "generate-037",
        "op": "generate",
        "target": "System/Windows/packages.manifest",
        "project": null,
        "reason": "Generate packages.manifest from extracted package installs"
      },
      {
        "id": "generate-038",
        "op": "generate",
        "target": "Home/microsoft.Windows/lifecycle.yaml",
        "project": "microsoft",
        "reason": "Convert script logic from Home/Configs/microsoft-Windows/Deploy-CosmosDB.ps1 to lifecycle.yaml"
      },
      {
        "id": "generate-039",
        "op": "generate",
        "target": "Home/microsoft.Windows/packages.manifest",
        "project": "microsoft",
        "reason": "Generate packages.manifest from extracted package installs"
      },
      {
        "id": "generate-040",
        "op": "generate",
        "target": "Home/all/lifecycle.yaml",
        "project": "all",
        "reason": "Convert script logic from Install-UnixUserConfiguration to lifecycle.yaml"
      },
      {
        "id": "generate-041",
        "op": "generate",
        "target": "Home/all.Windows/lifecycle.yaml",
        "project": "all",
        "reason": "Convert script logic from Install-WindowsUserConfiguration.ps1 to lifecycle.yaml"
      },
      {
        "id": "generate-042",
        "op": "generate",
        "target": "System/Windows/lifecycle.yaml",
        "project": null,
        "reason": "Convert script logic from Tools/Windows/FixUp-Acls.ps1 to lifecycle.yaml"
      },
      {
        "id": "generate-043",
        "op": "generate",
        "target": "System/Windows/lifecycle.yaml",
        "project": null,
        "reason": "Convert script logic from Tools/Windows/FixUp-Path.ps1 to lifecycle.yaml"
      },
      {
        "id": "generate-044",
        "op": "generate",
        "target": "System/Windows/lifecycle.yaml",
        "project": null,
        "reason": "Convert script logic from Tools/Windows/Initialize-OpenSsh.ps1 to lifecycle.yaml"
      },
      {
        "id": "generate-045",
        "op": "generate",
        "target": "System/Windows/lifecycle.yaml",
        "project": null,
        "reason": "Convert script logic from Tools/Windows/Install-ApacheMaven.ps1 to lifecycle.yaml"
      },
      {
        "id": "generate-046",
        "op": "generate",
        "target": "Home/all/.Personal-secrets/gnupg/lifecycle.yaml",
        "project": "all",
        "reason": "Convert script logic from .Personal-secrets/gnupg/Import-GnuPg.ps1 to lifecycle.yaml"
      },
      {
        "id": "remove-047",
        "op": "remove",
        "source": "Home/Configs",
        "reason": "Remove old Tuckr Configs directory"
      },
      {
        "id": "remove-048",
        "op": "remove",
        "source": "Tools",
        "reason": "Remove old Tools directory"
      },
      {
        "id": "remove-049",
        "op": "remove",
        "source": "Build-DarwinInitializationPackage",
        "reason": "Remove original lifecycle script Build-DarwinInitializationPackage"
      },
      {
        "id": "remove-050",
        "op": "remove",
        "source": "Build-DebianInitializationPackage",
        "reason": "Remove original lifecycle script Build-DebianInitializationPackage"
      },
      {
        "id": "remove-051",
        "op": "remove",
        "source": "Build-RHELInitializationPackage",
        "reason": "Remove original lifecycle script Build-RHELInitializationPackage"
      },
      {
        "id": "remove-052",
        "op": "remove",
        "source": "Build-WindowsInitializationPackage",
        "reason": "Remove original lifecycle script Build-WindowsInitializationPackage"
      },
      {
        "id": "remove-053",
        "op": "remove",
        "source": "Install-UnixUserConfiguration",
        "reason": "Remove original lifecycle script Install-UnixUserConfiguration"
      },
      {
        "id": "remove-054",
        "op": "remove",
        "source": "Install-WindowsUserConfiguration.ps1",
        "reason": "Remove original lifecycle script Install-WindowsUserConfiguration.ps1"
      },
      {
        "id": "remove-055",
        "op": "remove",
        "source": "Tools/Darwin/Initialize-Darwin",
        "reason": "Remove original lifecycle script Tools/Darwin/Initialize-Darwin"
      },
      {
        "id": "remove-056",
        "op": "remove",
        "source": "Tools/Debian/Initialize-Debian",
        "reason": "Remove original lifecycle script Tools/Debian/Initialize-Debian"
      },
      {
        "id": "remove-057",
        "op": "remove",
        "source": "Tools/RHEL/Initialize-RHEL",
        "reason": "Remove original lifecycle script Tools/RHEL/Initialize-RHEL"
      },
      {
        "id": "remove-058",
        "op": "remove",
        "source": "Tools/Windows/FixUp-Acls.ps1",
        "reason": "Remove original lifecycle script Tools/Windows/FixUp-Acls.ps1"
      },
      {
        "id": "remove-059",
        "op": "remove",
        "source": "Tools/Windows/FixUp-Path.ps1",
        "reason": "Remove original lifecycle script Tools/Windows/FixUp-Path.ps1"
      },
      {
        "id": "remove-060",
        "op": "remove",
        "source": "Tools/Windows/Initialize-OpenSsh.ps1",
        "reason": "Remove original lifecycle script Tools/Windows/Initialize-OpenSsh.ps1"
      },
      {
        "id": "remove-061",
        "op": "remove",
        "source": "Tools/Windows/Initialize-Windows.ps1",
        "reason": "Remove original lifecycle script Tools/Windows/Initialize-Windows.ps1"
      },
      {
        "id": "remove-062",
        "op": "remove",
        "source": "Tools/Windows/Install-ApacheMaven.ps1",
        "reason": "Remove original lifecycle script Tools/Windows/Install-ApacheMaven.ps1"
      },
      {
        "id": "remove-063",
        "op": "remove",
        "source": ".Personal-secrets/gnupg/Import-GnuPg.ps1",
        "reason": "Remove original lifecycle script .Personal-secrets/gnupg/Import-GnuPg.ps1"
      },
      {
        "id": "remove-064",
        "op": "remove",
        "source": "Inventory/Danoble-MBP-A.brews-installed",
        "reason": "Remove Inventory file Inventory/Danoble-MBP-A.brews-installed (not part of writ source)"
      },
      {
        "id": "remove-065",
        "op": "remove",
        "source": "Inventory/Danoble-MBP-A.ports-installed",
        "reason": "Remove Inventory file Inventory/Danoble-MBP-A.ports-installed (not part of writ source)"
      },
      {
        "id": "remove-066",
        "op": "remove",
        "source": "Inventory/Media-Server.brews-installed",
        "reason": "Remove Inventory file Inventory/Media-Server.brews-installed (not part of writ source)"
      },
      {
        "id": "remove-067",
        "op": "remove",
        "source": "Inventory/Media-Server.ports-installed",
        "reason": "Remove Inventory file Inventory/Media-Server.ports-installed (not part of writ source)"
      },
      {
        "id": "remove-068",
        "op": "remove",
        "source": "Inventory/dockerhost-us-wa-1.packages-installed",
        "reason": "Remove Inventory file Inventory/dockerhost-us-wa-1.packages-installed (not part of writ source)"
      },
      {
        "id": "remove-069",
        "op": "remove",
        "source": "Inventory/dockerhost-us-wa-2.packages-installed",
        "reason": "Remove Inventory file Inventory/dockerhost-us-wa-2.packages-installed (not part of writ source)"
      },
      {
        "id": "remove-070",
        "op": "remove",
        "source": "Deployments",
        "reason": "Remove Deployments directory (out of writ scope, manual migration needed)"
      },
      {
        "id": "remove-071",
        "op": "remove",
        "source": "Sync-CommonBuildTools",
        "reason": "Remove original lifecycle script Sync-CommonBuildTools"
      }
    ],
    "edges": [
      {
        "from": "mkdir-001",
        "to": "mkdir-002"
      },
      {
        "from": "mkdir-001",
        "to": "mkdir-003"
      },
      {
        "from": "mkdir-002",
        "to": "rename-004"
      },
      {
        "from": "mkdir-002",
        "to": "rename-005"
      },
      {
        "from": "mkdir-002",
        "to": "rename-006"
      },
      {
        "from": "mkdir-002",
        "to": "rename-007"
      },
      {
        "from": "mkdir-002",
        "to": "rename-008"
      },
      {
        "from": "mkdir-002",
        "to": "rename-009"
      },
      {
        "from": "mkdir-002",
        "to": "rename-010"
      },
      {
        "from": "mkdir-002",
        "to": "rename-011"
      },
      {
        "from": "mkdir-002",
        "to": "rename-012"
      },
      {
        "from": "mkdir-002",
        "to": "rename-013"
      },
      {
        "from": "mkdir-002",
        "to": "rename-014"
      },
      {
        "from": "mkdir-002",
        "to": "rename-015"
      },
      {
        "from": "mkdir-002",
        "to": "rename-016"
      },
      {
        "from": "mkdir-003",
        "to": "rename-017"
      },
      {
        "from": "mkdir-003",
        "to": "rename-018"
      },
      {
        "from": "mkdir-003",
        "to": "rename-019"
      },
      {
        "from": "mkdir-003",
        "to": "rename-020"
      },
      {
        "from": "decrypt-021",
        "to": "remove-022"
      },
      {
        "from": "decrypt-023",
        "to": "remove-024"
      },
      {
        "from": "decrypt-025",
        "to": "remove-026"
      },
      {
        "from": "decrypt-027",
        "to": "remove-028"
      },
      {
        "from": "rename-016",
        "to": "remove-047"
      },
      {
        "from": "rename-020",
        "to": "remove-048"
      }
    ]
  },
  "warnings": [
    {
      "message": "The 'Deployments' directory contains application-specific configurations and secrets. Writ focuses on user and system dotfiles. This directory is outside writ's core scope and requires manual migration or a separate deployment strategy.",
      "severity": "info",
      "mitigation": "Manually review and migrate 'Deployments' content. Consider using a dedicated application deployment tool or a separate writ repository if these are generic application configurations."
    },
    {
      "message": "Your current setup uses 'git-crypt' for encryption. Writ does not support git-crypt directly. Encrypted files will be decrypted and then re-encrypted using 'age' (or 'sops' if configured). This requires you to have access to the git-crypt decryption key/passphrase during migration.",
      "severity": "breaking",
      "mitigation": "Ensure your git-crypt repository is unlocked before starting the migration. The migration tool will attempt to decrypt and re-encrypt these files. Verify the new '.age' files are correctly encrypted and the original files are removed."
    },
    {
      "message": "The 'Install-UnixUserConfiguration' and 'Install-WindowsUserConfiguration.ps1' scripts contain complex logic for user identity resolution, git/ssh config generation, zsh function compilation, and Windows ACL management. This logic will be converted to 'lifecycle.yaml' scripts, but may require manual review and adaptation to writ's Go template syntax and lifecycle hooks.",
      "severity": "warning",
      "mitigation": "Carefully review the generated 'lifecycle.yaml' files. Test the deployment thoroughly on target systems to ensure all custom setup logic is correctly translated and executed."
    },
    {
      "message": "The 'Build-*InitializationPackage' scripts are complex build and distribution scripts for self-extracting, GPG-encrypted archives. Writ's deployment model replaces this approach. The package installation logic from these scripts has been extracted into 'packages.manifest' and 'lifecycle.yaml' files. The original build scripts will be removed.",
      "severity": "info",
      "mitigation": "Understand that writ manages dotfile deployment directly via 'writ add' and 'writ remove', eliminating the need for custom initialization packages. Verify that all necessary software is listed in the generated 'packages.manifest' files."
    },
    {
      "message": "The 'Inventory/' directory contains lists of installed packages (e.g., '.brews-installed', '.ports-installed'). These are typically generated reports, not source configuration files for writ. They will be removed during migration. The package lists for writ should be defined declaratively in 'packages.manifest' files.",
      "severity": "info",
      "mitigation": "Ensure that all desired packages are captured in the generated 'packages.manifest' files. The 'Inventory/' files themselves are not migrated."
    },
    {
      "message": "The script 'Sync-CommonBuildTools' uses rsync for synchronization. Writ's primary mechanism is symlinking from a single source of truth. If this script is used for non-dotfile synchronization, it should be managed separately or its functionality re-evaluated in the context of writ.",
      "severity": "info",
      "mitigation": "Review the purpose of 'Sync-CommonBuildTools'. If it's for managing files outside of $HOME or /etc, consider if it's still needed or if writ's capabilities can replace it."
    }
  ]
}
```
```

## Baseline Reference

See: knowledge/migration/examples/baseline-personal.json
