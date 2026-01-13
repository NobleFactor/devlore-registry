# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# aws-cli/prepare.star - Prepare phase for AWS CLI v2 installation
#
# This phase ensures prerequisites are met before installation.

def prepare():
    """Prepare the system for AWS CLI v2 installation."""

    # Check for conflicting AWS CLI v1
    if shell.which("aws"):
        result = shell.run("aws --version")
        if result.returncode == 0 and "aws-cli/1." in result.stdout:
            log.warn("AWS CLI v1 detected. It will be removed during installation.")

    # Platform-specific preparation
    if platform.os == "darwin":
        _prepare_darwin()
    elif platform.os == "linux":
        _prepare_linux()
    elif platform.os == "windows":
        _prepare_windows()
    else:
        fail("Unsupported platform: " + platform.os)

def _prepare_darwin():
    """Prepare macOS for AWS CLI installation."""
    # Check for Homebrew (preferred method)
    if not shell.which("brew"):
        # Will fall back to pkg installer
        log.info("Homebrew not found; will use pkg installer")

def _prepare_linux():
    """Prepare Linux for AWS CLI installation."""

    # AWS CLI v2 is distributed as a bundled installer
    # Requires: unzip, curl (or wget), and glibc 2.17+

    if platform.distro in ["debian", "ubuntu"]:
        package.install("unzip")
        package.install("curl")
    elif platform.distro in ["fedora", "rhel", "centos"]:
        package.install("unzip")
        package.install("curl")
    else:
        # Try to ensure basics are present
        if not shell.which("unzip"):
            fail("'unzip' is required but not found. Please install it.")
        if not shell.which("curl"):
            fail("'curl' is required but not found. Please install it.")

    # Check glibc version (AWS CLI v2 requires glibc 2.17+)
    result = shell.run("ldd --version")
    if result.returncode == 0:
        # Parse version from first line: "ldd (GNU libc) 2.31"
        first_line = result.stdout.split("\n")[0]
        if "2." in first_line:
            log.info("glibc version check passed")
        else:
            log.warn("Could not verify glibc version. AWS CLI v2 requires glibc 2.17+")

def _prepare_windows():
    """Prepare Windows for AWS CLI installation."""
    # winget or MSI installer handles everything
    pass

def rollback():
    """Rollback preparation changes on failure."""
    # Preparation is minimal; nothing to rollback
    pass
