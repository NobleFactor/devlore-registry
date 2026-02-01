# macports/Darwin/Decommission/cleanup.star - Cleanup phase for MacPorts

def cleanup():
    """Final cleanup of MacPorts installation remnants."""
    _remove_temporary_files()
    _cleanup_system_integration()
    _final_verification()
    return {"cleanup": True}

def _remove_temporary_files():
    """Remove temporary files and caches."""
    temp_files = [
        "/tmp/macports*",
        "/tmp/MacPorts*",
        "/tmp/*macports*"
    ]
    
    for pattern in temp_files:
        shell.exec(f"rm -rf {pattern}", allowed_commands=["rm"])
    
    # Remove user cache files
    user_home = env.expand("~")
    cache_dirs = [
        f"{user_home}/Library/Caches/org.macports.*",
        f"{user_home}/.cache/macports"
    ]
    
    for cache_dir in cache_dirs:
        if "*" in cache_dir:
            shell.exec(f"rm -rf {cache_dir}", allowed_commands=["rm"])
        elif fs.exists(cache_dir):
            fs.remove(cache_dir)
    
    print("Temporary files cleaned up")

def _cleanup_system_integration():
    """Remove system-level integrations."""
    # Remove any remaining launchd plists
    plist_locations = [
        "/Library/LaunchDaemons",
        "/Library/LaunchAgents",
        env.expand("~/Library/LaunchAgents")
    ]
    
    for location in plist_locations:
        if fs.exists(location):
            # Find MacPorts-related plists
            result = shell.exec(
                f"find {location} -name '*macports*' -o -name '*org.macports*'",
                allowed_commands=["find"]
            )
            
            if result.success and result.stdout.strip():
                plists = result.stdout.strip().split('\n')
                for plist in plists:
                    if plist.strip():
                        shell.exec(f"sudo rm {plist}", allowed_commands=["rm"])
                        print(f"Removed plist: {plist}")
    
    # Reload launchd to clear any cached references
    shell.exec("sudo launchctl reboot", allowed_commands=["launchctl"])

def _final_verification():
    """Verify MacPorts is completely removed."""
    # Check that port command is gone
    if fs.which("port"):
        print("WARNING: port command still found in PATH")
    
    # Check main directories are gone
    if fs.exists("/opt/local"):
        print("WARNING: /opt/local directory still exists")
    
    if fs.exists("/Applications/MacPorts"):
        print("WARNING: /Applications/MacPorts still exists")
    
    # Check for remaining processes
    result = shell.exec(
        "ps aux | grep -i macports | grep -v grep",
        allowed_commands=["ps", "grep"]
    )
    
    if result.success and result.stdout.strip():
        print("WARNING: MacPorts processes still running")
    
    print("MacPorts cleanup verification completed")

def rollback():
    """Rollback cleanup operations."""
    print("Cleanup rollback is not applicable - files have been permanently removed")
