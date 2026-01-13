# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# pandoc/verify.star - Verify phase for pandoc

def verify():
    """Verify pandoc installation is working."""

    # Check that pandoc command exists
    pandoc_path = shell.which("pandoc")
    if not pandoc_path:
        fail("pandoc command not found in PATH")

    # Check version output
    result = shell.run("pandoc --version")
    if result.returncode != 0:
        fail("'pandoc --version' failed: " + result.stderr)

    # Parse version
    version = _parse_version(result.stdout)
    if not version:
        fail("Could not parse pandoc version from output")

    log.info("pandoc version " + version + " is installed")

    # Verify PDF engine if enabled
    pdf_engine = None
    if package.feature("pdf-latex"):
        pdf_engine = _verify_latex()
    elif package.feature("pdf-weasyprint"):
        pdf_engine = _verify_weasyprint()
    elif package.feature("pdf-typst"):
        pdf_engine = _verify_typst()

    # Verify completions if enabled
    completions_installed = False
    if package.feature("completions"):
        completions_installed = _verify_completions()

    # THE REAL TEST: Can we actually generate a PDF?
    if pdf_engine:
        _verify_pdf_generation(pdf_engine)

    # Return success info for receipt
    return {
        "version": version,
        "path": pandoc_path,
        "pdf_engine": pdf_engine,
        "completions": completions_installed,
    }

def _parse_version(output):
    """Parse version string from pandoc version output."""
    # Output looks like:
    # pandoc 3.6
    # Features: +server +lua
    # ...
    for line in output.split("\n"):
        if line.startswith("pandoc "):
            parts = line.split()
            if len(parts) >= 2:
                return parts[1]
    return None

def _verify_latex():
    """Verify LaTeX PDF engine is working."""

    # Check for pdflatex or xelatex
    pdflatex = shell.which("pdflatex")
    xelatex = shell.which("xelatex")
    lualatex = shell.which("lualatex")

    if not pdflatex and not xelatex and not lualatex:
        fail("No LaTeX engine found (pdflatex, xelatex, or lualatex)")

    engine = "pdflatex"
    if xelatex:
        engine = "xelatex"  # Prefer XeLaTeX for Unicode support
    if lualatex:
        engine = "lualatex"  # Prefer LuaLaTeX if available

    log.info("LaTeX engine available: " + engine)

    # Check tlmgr for package management
    tlmgr = shell.which("tlmgr")
    if tlmgr:
        log.info("tlmgr available for LaTeX package management")
    else:
        log.warn("tlmgr not found — may not be able to install missing LaTeX packages")

    return engine

def _verify_weasyprint():
    """Verify WeasyPrint PDF engine is working."""

    weasyprint = shell.which("weasyprint")
    if not weasyprint:
        fail("weasyprint command not found")

    result = shell.run("weasyprint --version")
    if result.returncode != 0:
        fail("weasyprint --version failed: " + result.stderr)

    log.info("WeasyPrint available: " + result.stdout.strip())
    return "weasyprint"

def _verify_typst():
    """Verify Typst PDF engine is working."""

    typst = shell.which("typst")
    if not typst:
        fail("typst command not found")

    result = shell.run("typst --version")
    if result.returncode != 0:
        fail("typst --version failed: " + result.stderr)

    log.info("Typst available: " + result.stdout.strip())
    return "typst"

def _verify_completions():
    """Verify shell completions are installed."""

    user_shell = env.get("SHELL", "/bin/bash")
    completions_file = None

    if "bash" in user_shell:
        completions_file = fs.home() + "/.local/share/bash-completion/completions/pandoc"
    elif "zsh" in user_shell:
        completions_file = fs.home() + "/.local/share/zsh/site-functions/_pandoc"
    elif "fish" in user_shell:
        completions_file = fs.home() + "/.config/fish/completions/pandoc.fish"

    if completions_file and fs.exists(completions_file):
        log.info("Shell completions installed: " + completions_file)
        return True
    else:
        log.warn("Shell completions not found")
        return False

def _verify_pdf_generation(engine):
    """The ultimate test: actually generate a PDF.

    This catches the 'missing .sty' errors that plague new LaTeX installations.
    If this works, the user can confidently use pandoc for PDF generation.
    """

    # Create a test document
    test_md = "/tmp/lore-pandoc-test.md"
    test_pdf = "/tmp/lore-pandoc-test.pdf"

    test_content = """---
title: Lore Verification Test
author: lore
date: today
---

# Test Document

This document verifies that pandoc can generate PDFs correctly.

## Features Tested

- Basic markdown conversion
- Title page generation
- Section headers
- **Bold** and *italic* text

## Code Block

```python
def hello():
    print("Hello from pandoc!")
```

## Conclusion

If you can read this PDF, pandoc is working correctly.
"""

    fs.write(test_md, test_content)

    # Build pandoc command based on engine
    if engine in ["pdflatex", "xelatex", "lualatex"]:
        cmd = "pandoc " + test_md + " -o " + test_pdf + " --pdf-engine=" + engine
    elif engine == "weasyprint":
        cmd = "pandoc " + test_md + " -o " + test_pdf + " --pdf-engine=weasyprint"
    elif engine == "typst":
        cmd = "pandoc " + test_md + " -o " + test_pdf + " --pdf-engine=typst"
    else:
        cmd = "pandoc " + test_md + " -o " + test_pdf

    log.info("Testing PDF generation with " + engine + "...")
    result = shell.run(cmd, timeout = 60000)

    # Cleanup test file
    fs.remove(test_md)

    if result.returncode != 0:
        # This is the moment of truth — if this fails, the tribal knowledge is incomplete
        if fs.exists(test_pdf):
            fs.remove(test_pdf)

        error_msg = result.stderr
        if "missing" in error_msg.lower() and ".sty" in error_msg:
            # Extract the missing package name
            fail("PDF generation failed: missing LaTeX package. " +
                 "The provision phase may need additional tlmgr packages. " +
                 "Error: " + error_msg)
        else:
            fail("PDF generation failed: " + error_msg)

    # Verify the PDF was actually created and has content
    if not fs.exists(test_pdf):
        fail("PDF generation command succeeded but no PDF was created")

    # Check PDF has reasonable size (> 1KB)
    # Note: This would require a fs.size() function we may not have
    # For now, just check existence

    log.info("PDF generation successful!")
    fs.remove(test_pdf)

    return True
