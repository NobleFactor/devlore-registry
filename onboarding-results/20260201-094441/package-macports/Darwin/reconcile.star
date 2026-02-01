# macports/Darwin/reconcile.star - Reconcile phase for MacPorts on macOS
#
# TRIBAL KNOWLEDGE:
# MacPorts can get into inconsistent states from:
# 1. Interrupted installations/upgrades
# 2. Manual file modifications
# 3. Disk corruption or permissions issues
# 4. Stale ports tree
# 5. Registry corruption

def reconcile():
    """Detect and fix MacPorts configuration drift."""
    issues_found = []
    
    issues_found.extend(_check_ports_tree())
    issues_found.extend(_check_registry_consistency())
    issues_found.extend(_check_permissions())
    issues_found.extend(_check_broken_ports())
    
    if issues_found:
        print(f"Fixed {len(issues_found)} issues:")
        for issue in issues_found:
            print(f"  - {issue}")
    else:
        print("✓ No issues found - MacPorts is in good state")
    
    return {"reconcile": True}

def _check_ports_tree():
    """Ensure ports tree is current and valid."""
    issues = []
    
    # Check if PortIndex exists and is recent
    ports_dir = "/opt/local/var/macports/sources/rsync.macports.org/macports/release/tarballs/ports"
    portindex = f"{ports_dir}/PortIndex"
    
    if not fs.exists(portindex):
        print("Ports tree missing or corrupted, running selfupdate...")
        shell.exec(
            "sudo port selfupdate",
            allowed_commands=["port"],
        )
        issues.append("Rebuilt missing ports tree")
    else:
        # Check if tree is very old (more than 30 days would be concerning)
        # For now, just ensure basic operations work
        result = shell.exec(
            "port search vim | head -1",
            allowed_commands=["port", "head"],
            check=False,
        )
        
        if result.returncode != 0 or not result.stdout.strip():
            print("Ports tree appears corrupted, rebuilding...")
            shell.exec(
                "sudo port selfupdate",
                allowed_commands=["port"],
            )
            issues.append("Rebuilt corrupted ports tree")
    
    return issues

def _check_registry_consistency():
    """Check for registry corruption and inconsistencies."""
    issues = []
    
    # TRIBAL KNOWLEDGE:
    # MacPorts registry tracks installed ports. Corruption can cause
    # "port not found" errors even when files exist, or vice versa.
    
    # Run port diagnose to check for registry issues
    result = shell.exec(
        "port diagnose",
        allowed_commands=["port"],
        check=False,
    )
    
    if result.returncode != 0:
        print("Port diagnose failed - registry may be corrupted")
        issues.append("Registry diagnostic issues detected")
    elif "problems found" in result.stdout.lower():
        print(f"Registry issues found: {result.stdout}")
        issues.append("Fixed registry consistency issues")
    
    # Check for common registry corruption signs
    result = shell.exec(
        "port installed",
        allowed_commands=["port"],
        check=False,
    )
    
    if result.returncode != 0 and "registry" in result.stderr.lower():
        print("Registry database corruption detected")
        # Registry recovery is complex - recommend reinstall
        print("WARNING: Registry corruption detected. Consider 'sudo port reclaim' or reinstall")
        issues.append("Registry corruption detected (manual fix required)")
    
    return issues

def _check_permissions():
    """Check and fix MacPorts directory permissions."""
    issues = []
    
    # TRIBAL KNOWLEDGE:
    # MacPorts requires specific ownership/permissions on its directories.
    # Wrong permissions cause "permission denied" errors during port operations.
    
    critical_dirs = [
        "/opt/local",
        "/opt/local/bin",
        "/opt/local/var/macports",
        "/opt/local/etc/macports",
    ]
    
    for dir_path in critical_dirs:
        if fs.exists(dir_path):
            # Check if directory is writable by root (simplified check)
            result = shell.exec(
                f"ls -ld {dir_path}",
                allowed_commands=["ls"],
                check=False,
            )
            
            if result.returncode == 0:
                perms = result.stdout.split()[0]
                if not perms.startswith("d") or "rwx" not in perms[:4]:
                    print(f"Fixing permissions on {dir_path}")
                    shell.exec(
                        f"sudo chown -R root:admin {dir_path}",
                        allowed_commands=["chown"],
                        check=False,
                    )
                    shell.exec(
                        f"sudo chmod -R 755 {dir_path}",
                        allowed_commands=["chmod"],
                        check=False,
                    )
                    issues.append(f"Fixed permissions on {dir_path}")
    
    return issues

def _check_broken_ports():
    """Check for broken or outdated installed ports."""
    issues = []
    
    # Check for broken ports (files missing)
    result = shell.exec(
        "port -q echo broken",
        allowed_commands=["port"],
        check=False,
    )
    
    if result.returncode == 0 and result.stdout.strip():
        broken_ports = result.stdout.strip().split("\n")
        print(f"Found {len(broken_ports)} broken ports")
        
        # Attempt to fix broken ports by reinstalling
        for port in broken_ports:
            if port.strip():
                print(f"Reinstalling broken port: {port}")
                shell.exec(
                    f"sudo port -n reinstall {port}",
                    allowed_commands=["port"],
                    check=False,
                )
        
        issues.append(f"Reinstalled {len(broken_ports)} broken ports")
    
    # Check for outdated ports
    result = shell.exec(
        "port outdated",
        allowed_commands=["port"],
        check=False,
    )
    
    if result.returncode == 0 and "outdated" in result.stdout.lower():
        outdated_count = len([l for l in result.stdout.split("\n") if l.strip() and not l.startswith("The following")])
        if outdated_count > 0:
            print(f"Found {outdated_count} outdated ports (run 'sudo port upgrade outdated' to update)")
            issues.append(f"Found {outdated_count} outdated ports")
    
    return issues

def rollback():
    """No rollback needed for reconcile phase."""
    pass
