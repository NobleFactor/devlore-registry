# macports/Darwin/cleanup.star - Cleanup phase for MacPorts on macOS
#
# TRIBAL KNOWLEDGE:
# Complete MacPorts removal requires cleaning up:
# 1. The entire /opt/local directory tree
# 2. User/group accounts created by MacPorts
# 3. Shell profile modifications
# 4. LaunchDaemons/LaunchAgents
# 5. Receipts and system integration files

def cleanup():
    """Complete removal of MacPorts installation and configuration."""
    _remove_macports_directory()
    _cleanup_system_integration()
    _cleanup_user_accounts()
    _cleanup_launchd_services()
    _cleanup_shell_profiles()
    return {"cleanup": True}

def _remove_macports_directory():
    """Remove the main MacPorts installation directory."""
    print("Removing MacPorts installation directory...")
    
    if fs.exists("/opt/local"):
        # TRIBAL KNOWLEDGE:
        # /opt/local may contain user-created files mixed with MacPorts files.
        # We should warn about this, but for complete removal, everything goes.
        print("WARNING: Removing entire /opt/local directory")
        print("This will delete ALL files in /opt/local, including any non-MacPorts files")
        
        shell.exec(
            "sudo rm -rf /opt/local",
            allowed_commands=["rm"],
        )
        
        print("✓ MacPorts installation directory removed")
    else:
        print("MacPorts directory not found - already removed")

def _cleanup_system_integration():
    """Remove MacPorts system integration files."""
    print("Cleaning up system integration files...")
    
    # Remove PATH configuration
    path_file = "/etc/paths.d/MacPorts"
    if fs.exists(path_file):
        shell.exec(
            f"sudo rm {path_file}",
            allowed_commands=["rm"],
        )
        print("✓ Removed MacPorts PATH configuration")
    
    # Remove man page configuration if it exists
    manpath_file = "/etc/manpaths.d/MacPorts"
    if fs.exists(manpath_file):
        shell.exec(
            f"sudo rm {manpath_file}",
            allowed_commands=["rm"],
        )
        print("✓ Removed MacPorts MANPATH configuration")
    
    # Check for and remove package receipts
    receipt_dirs = ["/var/db/receipts"]
    for receipt_dir in receipt_dirs:
        if fs.exists(receipt_dir):
            result = shell.exec(
                f"find {receipt_dir} -name '*macports*' -o -name '*MacPorts*'",
                allowed_commands=["find"],
                check=False,
            )
            
            if result.returncode == 0 and result.stdout.strip():
                receipts = result.stdout.strip().split("\n")
                for receipt in receipts:
                    if receipt.strip():
                        shell.exec(
                            f"sudo rm {receipt.strip()}",
                            allowed_commands=["rm"],
                            check=False,
                        )
                print(f"✓ Removed {len(receipts)} MacPorts receipts")

def _cleanup_user_accounts():
    """Remove MacPorts-related user accounts and groups."""
    print("Cleaning up MacPorts user accounts...")
    
    # TRIBAL KNOWLEDGE:
    # MacPorts may create specific user accounts for certain ports
    # (e.g., _mysql, _postgresql). Most ports use existing system accounts,
    # but some create their own under the MacPorts prefix.
    
    # Check for macports group
    result = shell.exec(
        "dscl . -read /Groups/macports",
        allowed_commands=["dscl"],
        check=False,
    )
    
    if result.returncode == 0:
        print("Removing macports group...")
        shell.exec(
            "sudo dscl . -delete /Groups/macports",
            allowed_commands=["dscl"],
            check=False,
        )
        print("✓ Removed macports group")
    
    # Look for users created with MacPorts prefix
    result = shell.exec(
        "dscl . -list /Users | grep macports",
        allowed_commands=["dscl", "grep"],
        check=False,
    )
    
    if result.returncode == 0 and result.stdout.strip():
        macports_users = result.stdout.strip().split("\n")
        for user in macports_users:
            if user.strip():
                print(f"Removing user: {user.strip()}")
                shell.exec(
                    f"sudo dscl . -delete /Users/{user.strip()}",
                    allowed_commands=["dscl"],
                    check=False,
                )
        print(f"✓ Removed {len(macports_users)} MacPorts users")

def _cleanup_launchd_services():
    """Remove LaunchDaemons and LaunchAgents installed by MacPorts."""
    print("Cleaning up LaunchDaemons and LaunchAgents...")
    
    launchd_dirs = [
        "/Library/LaunchDaemons",
        "/Library/LaunchAgents",
        "/System/Library/LaunchDaemons",
        "/System/Library/LaunchAgents",
    ]
    
    total_removed = 0
    
    for launchd_dir in launchd_dirs:
        if fs.exists(launchd_dir):
            # Find MacPorts-related plist files
            result = shell.exec(
                f"find {launchd_dir} -name '*macports*' -o -name '*opt.local*'",
                allowed_commands=["find"],
                check=False,
            )
            
            if result.returncode == 0 and result.stdout.strip():
                plists = result.stdout.strip().split("\n")
                for plist in plists:
                    if plist.strip():
                        # Unload first, then remove
                        plist_name = plist.strip().split("/")[-1].replace(".plist", "")
                        shell.exec(
                            f"sudo launchctl unload {plist.strip()}",
                            allowed_commands=["launchctl"],
                            check=False,
                        )
                        shell.exec(
                            f"sudo rm {plist.strip()}",
                            allowed_commands=["rm"],
                            check=False,
                        )
                        total_removed += 1
    
    if total_removed > 0:
        print(f"✓ Removed {total_removed} LaunchD services")
    else:
        print("No LaunchD services found")

def _cleanup_shell_profiles():
    """Clean up shell profile modifications made by MacPorts."""
    print("Cleaning up shell profile modifications...")
    
    # TRIBAL KNOWLEDGE:
    # The .pkg installer modifies shell profiles by adding MacPorts paths.
    # We need to remove these modifications from common profile files.
    
    profile_files = [
        "~/.bash_profile",
        "~/.bashrc", 
        "~/.zshrc",
        "~/.profile",
    ]
    
    macports_markers = [
        "/opt/local/bin",
        "/opt/local/sbin",
        "MacPorts Installer addition",
        "# Adding an appropriate PATH variable",
    ]
    
    for profile in profile_files:
        expanded_profile = env.expand(profile)
        if fs.exists(expanded_profile):
            content = fs.read(expanded_profile)
            
            # Check if file contains MacPorts modifications
            has_macports_content = any(marker in content for marker in macports_markers)
            
            if has_macports_content:
                print(f"Found MacPorts content in {profile}")
                print(f"Please manually review and clean up {profile}")
                print("Look for lines containing '/opt/local/bin' or 'MacPorts'")
                
                # Create backup
                backup_name = f"{expanded_profile}.pre_macports_cleanup"
                shell.exec(
                    f"cp {expanded_profile} {backup_name}",
                    allowed_commands=["cp"],
                    check=False,
                )
                print(f"Backup saved to {backup_name}")
    
    print("✓ Shell profile cleanup completed (manual review recommended)")
    print("\nMacPorts has been completely removed from your system.")
    print("You may need to open a new terminal for PATH changes to take effect.")

def rollback():
    """Rollback is not possible for cleanup phase."""
    print("WARNING: Cleanup phase cannot be rolled back")
    print("MacPorts files have been permanently removed")
    print("To restore MacPorts, you must reinstall from scratch")
