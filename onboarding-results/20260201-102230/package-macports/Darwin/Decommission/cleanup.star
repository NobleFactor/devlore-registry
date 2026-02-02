# macports/Darwin/Decommission/cleanup.star
#
# TRIBAL KNOWLEDGE:
# Final cleanup after MacPorts removal should eliminate all traces
# while preserving user data and system stability.

def cleanup(package, system, plan):
    """Final cleanup after MacPorts uninstall."""
    
    # Clean up temporary files created during decommission
    _cleanup_temp_files(package, system, plan)
    
    # Remove any remaining MacPorts traces
    _cleanup_remaining_traces(package, system, plan)
    
    # Clean system caches that might reference MacPorts
    _cleanup_system_caches(package, system, plan)
    
    # Provide final cleanup report
    _generate_cleanup_report(package, system, plan)
    
    return {"cleanup": True}

def _cleanup_temp_files(package, system, plan):
    """Remove temporary files created during decommission process.
    
    TRIBAL KNOWLEDGE:
    Decommission process creates various temporary files:
    - Port backup lists
    - Configuration backups  
    - Migration logs
    """
    # Remove our temporary files (but preserve user backups)
    cleanup_temp = plan.shell("""
        # Remove temporary port lists (but keep user backups)
        sudo rm -f /tmp/macports_*.txt || true
        
        # Remove temporary build artifacts
        sudo rm -rf /tmp/mp-* || true
        
        # Remove any temporary downloads
        rm -f /tmp/macports.pkg || true
    """)

def _cleanup_remaining_traces(package, system, plan):
    """Remove any remaining MacPorts traces from system.
    
    TRIBAL KNOWLEDGE:
    Even after main uninstall, traces can remain in:
    - Shell command history
    - System logs
    - Spotlight index
    - Package receipt database
    """
    # Remove package receipts if installed via .pkg
    remove_receipts = plan.shell("""
        # Remove MacPorts package receipts
        for receipt in $(pkgutil --pkgs | grep org.macports); do
            sudo pkgutil --forget $receipt || true
        done
    """)
    
    # Clear bash/zsh history entries containing 'port'
    # (This is optional - some users might want to keep history)
    clean_history_info = plan.shell("""
        echo "Note: MacPorts commands remain in shell history."
        echo "To remove: history | grep port | cut -c8- | while read line; do history -d \"\$line\"; done"
    """)

def _cleanup_system_caches(package, system, plan):
    """Clean system caches that might reference MacPorts.
    
    TRIBAL KNOWLEDGE:
    macOS caches various information that might reference MacPorts:
    - Launch Services database (for applications)
    - Spotlight index
    - Dynamic linker cache
    """
    # Rebuild Launch Services database to remove MacPorts app references
    rebuild_lsdb = plan.shell("/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user")
    
    # Update locate database if it exists
    update_locate = plan.shell("sudo /usr/libexec/locate.updatedb || true")
    
    # Clear any relevant system caches
    clear_caches = plan.shell("""
        # Clear system font cache (in case MacPorts installed fonts)
        sudo atsutil databases -remove || true
        
        # Clear dynamic linker cache
        sudo update_dyld_shared_cache -force || true
    """)

def _generate_cleanup_report(package, system, plan):
    """Generate final report of cleanup actions.
    
    TRIBAL KNOWLEDGE:
    Provide user with summary of what was removed and any
    manual actions they might want to take.
    """
    generate_report = plan.shell("""
        echo "MacPorts Decommission Complete"
        echo "=============================="
        echo
        echo "Removed:"
        echo "- MacPorts base installation"
        echo "- All installed ports"
        echo "- Configuration files"
        echo "- Environment setup"
        echo "- System integration"
        echo
        echo "Preserved (if they exist):"
        echo "- ~/macports_removed_*.txt (port backup lists)"
        echo "- ~/macports_etc_backup_*.tar.gz (configuration backups)"
        echo
        echo "Manual cleanup (optional):"
        echo "- Remove MacPorts references from shell history"
        echo "- Review and remove any custom configurations"
        echo "- Restart terminal sessions for clean environment"
        echo
        echo "To reinstall MacPorts:"
        echo "- Download installer from https://www.macports.org/install.php"
        echo "- Restore from backups if desired"
        echo
    """)

def rollback(package, system, plan):
    """Rollback cleanup operations.
    
    TRIBAL KNOWLEDGE:
    Cleanup rollback is mostly informational since cleanup
    operations are generally safe and reversible.
    """
    rollback_info = """
Cleanup rollback notes:

- Temporary files: Generally safe to remove, recreated as needed
- System caches: Automatically rebuilt by macOS as needed  
- Package receipts: Only affects pkgutil queries
- Launch Services: Rebuilt automatically

No action required for cleanup rollback.
If you want to reinstall MacPorts, use standard installation process.
"""
    
    return {"rollback": "info_only", "info": rollback_info}
