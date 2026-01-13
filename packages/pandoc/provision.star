# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# pandoc/provision.star - Provision phase for pandoc
#
# THIS IS WHERE THE TRIBAL KNOWLEDGE LIVES
#
# The "invisible dependency" problem: pandoc + basictex doesn't work out of the box.
# You'll get "missing bookmark.sty", "missing xcolor.sty", etc.
# These packages must be installed via tlmgr (TeX Live Manager), a second
# package manager that lives inside texlive and is invisible to brew/apt/etc.
#
# This list was compiled through painful trial and error. It represents
# hours of debugging distilled into a few lines of code.

def provision():
    """Configure pandoc after installation."""

    # Install tlmgr packages if using LaTeX PDF engine
    if package.feature("pdf-latex"):
        distribution = package.setting("latex_distribution", "basic")

        # Full distributions include everything; no tlmgr needed
        if distribution != "full":
            _provision_latex_packages()

    # Configure default paper size
    if package.feature("pdf-latex") or package.feature("pdf-weasyprint"):
        _configure_paper_size()

    # Install shell completions
    if package.feature("completions"):
        _install_completions()

def _provision_latex_packages():
    """Install the LaTeX packages pandoc actually needs.

    This is the tribal knowledge that takes hours to discover:
    - bookmark.sty: PDF bookmarks (required for --toc)
    - xcolor.sty: Color support (required by many templates)
    - mdwtools: Footnotes in tables
    - koma-script: European document classes
    - footmisc: Footnote customization
    - footnotebackref: Backlinks from footnotes
    - fancyhdr: Headers and footers
    - titling: Title page customization
    - csquotes: Smart quotes
    - selnolig: Ligature suppression
    - upquote: Straight quotes in verbatim
    - microtype: Micro-typography improvements
    - parskip: Paragraph spacing
    - xurl: Better URL line breaks
    - unicode-math: Unicode math support
    - mathspec: Math font selection (XeTeX)
    - fontspec: Font selection (XeTeX/LuaTeX)
    """

    # Find tlmgr
    tlmgr_path = _find_tlmgr()
    if not tlmgr_path:
        log.warn("tlmgr not found — cannot install LaTeX packages")
        log.warn("PDF generation may fail with 'missing .sty' errors")
        return

    # The packages pandoc templates commonly need
    # Ordered by frequency of "missing X" errors
    packages = [
        # Critical — almost always needed
        "collection-fontsrecommended",  # Basic fonts
        "bookmark",                      # PDF bookmarks
        "xcolor",                        # Colors

        # Commonly needed
        "mdwtools",                      # Footnotes in tables
        "koma-script",                   # Document classes
        "footmisc",                      # Footnote options
        "footnotebackref",               # Footnote backlinks
        "fancyhdr",                      # Headers/footers
        "titling",                       # Title formatting
        "csquotes",                      # Smart quotes

        # Typography improvements
        "selnolig",                      # Ligature control
        "upquote",                       # Straight quotes in code
        "microtype",                     # Micro-typography
        "parskip",                       # Paragraph spacing

        # URL and link handling
        "xurl",                          # URL line breaks
        "hyperref",                      # Hyperlinks (usually included)

        # Math and fonts (for XeTeX/LuaTeX)
        "unicode-math",
        "mathspec",
        "fontspec",

        # Tables
        "booktabs",                      # Professional tables
        "longtable",                     # Multi-page tables
        "multirow",                      # Multi-row cells

        # Graphics
        "adjustbox",                     # Box adjustments
        "graphicx",                      # Graphics inclusion

        # Misc
        "etoolbox",                      # Programming tools
        "xifthen",                       # Conditionals
        "ifmtarg",                       # Empty argument test
        "environ",                       # Environment handling
    ]

    log.info("Installing LaTeX packages via tlmgr (this may take a few minutes)...")

    # Update tlmgr first
    result = shell.run(tlmgr_path + " update --self", timeout = 120000)
    if result.returncode != 0:
        log.warn("tlmgr self-update failed (continuing anyway): " + result.stderr)

    # Install packages
    failed = []
    for pkg in packages:
        result = shell.run(tlmgr_path + " install " + pkg, timeout = 60000)
        if result.returncode != 0:
            failed.append(pkg)
            log.warn("Failed to install " + pkg + ": " + result.stderr)
        else:
            log.info("Installed: " + pkg)

    if failed:
        log.warn("Some LaTeX packages failed to install: " + ", ".join(failed))
        log.warn("PDF generation may encounter 'missing .sty' errors")
    else:
        log.info("All LaTeX packages installed successfully")

def _find_tlmgr():
    """Find the tlmgr executable."""

    # Check PATH first
    tlmgr = shell.which("tlmgr")
    if tlmgr:
        return tlmgr

    # Common locations
    locations = []

    if platform.os == "darwin":
        locations = [
            "/Library/TeX/texbin/tlmgr",
            "/usr/local/texlive/2024/bin/universal-darwin/tlmgr",
            "/usr/local/texlive/2023/bin/universal-darwin/tlmgr",
        ]
    elif platform.os == "linux":
        locations = [
            "/usr/bin/tlmgr",
            "/usr/local/texlive/2024/bin/x86_64-linux/tlmgr",
            "/usr/local/texlive/2023/bin/x86_64-linux/tlmgr",
        ]

    for loc in locations:
        if fs.exists(loc):
            return loc

    return None

def _configure_paper_size():
    """Configure default paper size."""

    paper = package.setting("paper", "letter")

    # For LaTeX, set via texconfig or environment
    if package.feature("pdf-latex"):
        tlmgr = _find_tlmgr()
        if tlmgr:
            result = shell.run(tlmgr + " paper " + paper)
            if result.returncode == 0:
                log.info("Set LaTeX paper size to: " + paper)

def _install_completions():
    """Install shell completions for pandoc."""

    user_shell = env.get("SHELL", "/bin/bash")

    if "bash" in user_shell:
        completions_dir = fs.home() + "/.local/share/bash-completion/completions"
        fs.mkdir(completions_dir, parents = True)

        result = shell.run("pandoc --bash-completion")
        if result.returncode == 0:
            fs.write(completions_dir + "/pandoc", result.stdout)
            log.info("Installed bash completions for pandoc")

    elif "zsh" in user_shell:
        completions_dir = fs.home() + "/.local/share/zsh/site-functions"
        fs.mkdir(completions_dir, parents = True)

        result = shell.run("pandoc --zsh-completion")
        if result.returncode == 0:
            fs.write(completions_dir + "/_pandoc", result.stdout)
            log.info("Installed zsh completions for pandoc")

    elif "fish" in user_shell:
        completions_dir = fs.home() + "/.config/fish/completions"
        fs.mkdir(completions_dir, parents = True)

        result = shell.run("pandoc --fish-completion")
        if result.returncode == 0:
            fs.write(completions_dir + "/pandoc.fish", result.stdout)
            log.info("Installed fish completions for pandoc")

def rollback():
    """Rollback provisioning changes on failure."""

    # Remove completions
    completions_files = [
        fs.home() + "/.local/share/bash-completion/completions/pandoc",
        fs.home() + "/.local/share/zsh/site-functions/_pandoc",
        fs.home() + "/.config/fish/completions/pandoc.fish",
    ]

    for f in completions_files:
        if fs.exists(f):
            fs.remove(f)

    # Note: We don't remove tlmgr packages as they may be used by other tools
