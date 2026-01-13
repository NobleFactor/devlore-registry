# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# pandoc/prepare.star - Prepare phase for pandoc installation

def prepare():
    """Prepare the system for pandoc installation."""

    # Check platform
    if platform.os not in ["darwin", "linux", "windows"]:
        fail("Unsupported platform: " + platform.os)

    # If pdf-latex feature is enabled, check for conflicting LaTeX installations
    if package.feature("pdf-latex"):
        _check_latex_conflicts()

    # If pdf-weasyprint feature is enabled, check Python availability
    if package.feature("pdf-weasyprint"):
        if not shell.which("python3"):
            fail("WeasyPrint requires Python 3")

def _check_latex_conflicts():
    """Check for conflicting LaTeX installations."""

    if platform.os == "darwin":
        # Check for MacTeX vs BasicTeX conflict
        mactex_installed = fs.exists("/Library/TeX/texbin/pdflatex")
        basictex_check = shell.run("brew list --cask basictex 2>/dev/null", shell = True)
        mactex_check = shell.run("brew list --cask mactex 2>/dev/null", shell = True)

        if mactex_installed:
            log.info("Existing LaTeX installation found at /Library/TeX")
            # Don't fail — we'll use the existing installation

    elif platform.os == "linux":
        # Check for texlive installations
        texlive_full = shell.which("pdflatex")
        if texlive_full:
            log.info("Existing LaTeX installation found: " + texlive_full)

def rollback():
    """Rollback preparation changes on failure."""
    # Nothing to rollback in prepare phase
    pass
