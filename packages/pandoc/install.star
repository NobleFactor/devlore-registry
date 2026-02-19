# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# pandoc/install.star - Install phase for pandoc

def install():
    """Install pandoc and optional PDF engines."""

    # Install pandoc itself
    if platform.os == "darwin":
        _install_darwin()
    elif platform.os == "linux":
        _install_linux()
    elif platform.os == "windows":
        _install_windows()

    # Install PDF engine if requested
    if package.feature("pdf-latex"):
        _install_latex()
    elif package.feature("pdf-weasyprint"):
        _install_weasyprint()
    elif package.feature("pdf-typst"):
        _install_typst()

def _install_darwin():
    """Install pandoc on macOS."""

    if shell.which("brew"):
        package.install("pandoc", manager = "brew")
    elif shell.which("port"):
        package.install("pandoc", manager = "port")
    else:
        _install_from_github()

def _install_linux():
    """Install pandoc on Linux."""

    if platform.distro in ["debian", "ubuntu"]:
        # Debian/Ubuntu repo version is often outdated
        # Use GitHub release for latest
        _install_from_github()

    elif platform.distro in ["fedora", "rhel", "centos"]:
        package.install("pandoc", manager = "dnf")

    elif platform.distro == "arch":
        package.install("pandoc", manager = "pacman")

    else:
        _install_from_github()

def _install_windows():
    """Install pandoc on Windows."""

    if shell.which("winget"):
        package.install("JohnMacFarlane.Pandoc", manager = "winget")
    elif shell.which("choco"):
        package.install("pandoc", manager = "choco")
    else:
        fail("No package manager found. Install winget or chocolatey.")

def _install_from_github():
    """Install pandoc from GitHub releases."""

    # Determine architecture
    if platform.arch == "arm64":
        arch_suffix = "arm64"
    else:
        arch_suffix = "amd64"

    if platform.os == "darwin":
        archive_name = "pandoc-3.6-macOS.pkg"
        url = "https://github.com/jgm/pandoc/releases/download/3.6/" + archive_name
        dest = "/tmp/" + archive_name

        http.download(url = url, dest = dest)
        result = shell.run("sudo installer -pkg " + dest + " -target /")
        if result.returncode != 0:
            fail("Failed to install pandoc: " + result.stderr)
        fs.remove(dest)

    elif platform.os == "linux":
        archive_name = "pandoc-3.6-linux-" + arch_suffix + ".tar.gz"
        url = "https://github.com/jgm/pandoc/releases/download/3.6/" + archive_name
        dest = "/tmp/" + archive_name

        http.download(url = url, dest = dest)
        archive.extract(path = dest, dest = "/tmp/pandoc-extract", strip = 1)

        # Install to /usr/local/bin
        fs.copy(src = "/tmp/pandoc-extract/bin/pandoc", dest = "/usr/local/bin/pandoc")
        fs.chmod(path = "/usr/local/bin/pandoc", mode = 0o755)

        # Cleanup
        fs.remove(dest)
        fs.remove("/tmp/pandoc-extract", recursive = True)

def _install_latex():
    """Install LaTeX distribution based on settings."""

    distribution = package.setting("latex_distribution", "basic")

    if platform.os == "darwin":
        if distribution == "full":
            package.install("mactex", manager = "brew", cask = True)
        else:
            package.install("basictex", manager = "brew", cask = True)

    elif platform.os == "linux":
        if platform.distro in ["debian", "ubuntu"]:
            if distribution == "full":
                package.install("texlive-full", manager = "apt")
            elif distribution == "medium":
                package.install("texlive-latex-recommended", manager = "apt")
                package.install("texlive-fonts-recommended", manager = "apt")
            else:
                package.install("texlive-latex-base", manager = "apt")

        elif platform.distro in ["fedora", "rhel", "centos"]:
            if distribution == "full":
                package.install("texlive-scheme-full", manager = "dnf")
            else:
                package.install("texlive-scheme-basic", manager = "dnf")

    elif platform.os == "windows":
        # MiKTeX is the standard Windows LaTeX
        if shell.which("winget"):
            package.install("MiKTeX.MiKTeX", manager = "winget")
        elif shell.which("choco"):
            package.install("miktex", manager = "choco")

def _install_weasyprint():
    """Install WeasyPrint PDF engine."""

    if platform.os == "darwin":
        package.install("weasyprint", manager = "brew")

    elif platform.os == "linux":
        if platform.distro in ["debian", "ubuntu"]:
            package.install("weasyprint", manager = "apt")
        elif platform.distro in ["fedora", "rhel", "centos"]:
            package.install("weasyprint", manager = "dnf")
        else:
            # Fallback to pip
            shell.run("pip3 install weasyprint")

    elif platform.os == "windows":
        shell.run("pip install weasyprint")

def _install_typst():
    """Install Typst PDF engine."""

    if platform.os == "darwin":
        package.install("typst", manager = "brew")

    elif platform.os == "linux":
        # Typst not in most distro repos yet, use cargo or binary
        if shell.which("cargo"):
            shell.run("cargo install typst-cli")
        else:
            # Download binary
            arch = "x86_64" if platform.arch == "amd64" else "aarch64"
            url = "https://github.com/typst/typst/releases/latest/download/typst-" + arch + "-unknown-linux-musl.tar.xz"
            http.download(url = url, dest = "/tmp/typst.tar.xz")
            archive.extract(path = "/tmp/typst.tar.xz", dest = "/tmp/typst-extract")
            fs.copy(src = "/tmp/typst-extract/typst", dest = "/usr/local/bin/typst")
            fs.chmod(path = "/usr/local/bin/typst", mode = 0o755)

    elif platform.os == "windows":
        if shell.which("winget"):
            package.install("Typst.Typst", manager = "winget")

