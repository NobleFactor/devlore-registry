# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Noble Factor. All rights reserved.
#
# xcode-clt/verify.star - Verify phase for Xcode Command Line Tools
#
# TRIBAL KNOWLEDGE - VERIFICATION STRATEGY:
#
# Simply checking "does clang exist?" is insufficient. We've seen installations
# where:
# - The binary exists but fails with license errors
# - The binary exists but is missing dynamic libraries
# - xcode-select points to a nonexistent path
# - pkgutil shows installed but tools don't actually work
#
# The only reliable verification is to actually USE the tools:
# 1. Check tool binaries exist and are executable
# 2. Run version commands to verify tools are functional
# 3. (Optional) Compile a test program to verify the full toolchain
#
# The comprehensive verify compiles actual code because:
# - It tests the compiler, linker, and system libraries together
# - It catches missing SDK headers or frameworks
# - It validates the toolchain can produce working binaries

_CLT_PATH = "/Library/Developer/CommandLineTools"


def verify():
    """Verify Xcode Command Line Tools installation is working."""

    results = {
        "verified": False,
        "tools": {},
        "path": "",
        "version": "",
        "sdk_path": "",
        "compilation_test": False,
    }

    # Verify xcode-select path
    results["path"] = _verify_xcode_select()

    # Verify core tools exist and work
    results["tools"]["clang"] = _verify_clang()
    results["tools"]["git"] = _verify_git()
    results["tools"]["make"] = _verify_make()
    results["tools"]["ld"] = _verify_linker()

    # Verify SDK is available
    results["sdk_path"] = _verify_sdk()

    # Get overall version
    results["version"] = results["tools"]["clang"].get("version", "")

    # Comprehensive verification: actually compile something
    if package.feature("verify-full"):
        results["compilation_test"] = _verify_compilation()

    # Check if Rosetta is working (if requested on ARM)
    if platform.arch == "arm64" and package.feature("rosetta"):
        results["rosetta"] = _verify_rosetta()

    # Determine overall success
    core_ok = all([
        results["tools"]["clang"].get("ok", False),
        results["tools"]["git"].get("ok", False),
        results["tools"]["make"].get("ok", False),
    ])

    if not core_ok:
        error("Core tools verification failed. CLT may be corrupted or incompletely installed.")

    if package.feature("verify-full") and not results["compilation_test"]:
        warn("Compilation test failed. Some build operations may not work correctly.")

    results["verified"] = True
    note("Xcode Command Line Tools verification passed")
    note("  clang: " + results["tools"]["clang"].get("version", "unknown"))
    note("  git: " + results["tools"]["git"].get("version", "unknown"))
    note("  SDK: " + results["sdk_path"])

    return results


def _verify_xcode_select():
    """Verify xcode-select is configured correctly.

    Returns:
        str: Developer directory path
    """

    result = shell.exec(
        command = "xcode-select -p",
        allowed_commands = ["xcode-select"],
    )

    if not result.ok:
        error("xcode-select not configured: " + result.stderr)

    path = result.stdout.strip()

    if not fs.exists(path):
        error("xcode-select path does not exist: " + path)

    note("Developer directory: " + path)
    return path


def _verify_clang():
    """Verify clang compiler is working.

    Returns:
        dict: {ok: bool, path: str, version: str}
    """

    result = {
        "ok": False,
        "path": "",
        "version": "",
    }

    # Find clang
    clang_path = fs.which("clang")
    if not clang_path:
        warn("clang not found in PATH")
        return result

    result["path"] = clang_path

    # Get version
    version_result = shell.exec(
        command = "clang --version",
        allowed_commands = ["clang"],
    )

    if not version_result.ok:
        warn("clang --version failed: " + version_result.stderr)
        # Check for license error
        if "license" in version_result.stderr.lower():
            error("Xcode license not accepted. Run: sudo xcodebuild -license accept")
        return result

    # Parse version from output
    # "Apple clang version 15.0.0 (clang-1500.0.40.1)"
    output = version_result.stdout
    for line in output.split("\n"):
        if "Apple clang version" in line:
            parts = line.split("Apple clang version ")
            if len(parts) > 1:
                result["version"] = parts[1].split(" ")[0]
            break
        elif "clang version" in line:
            # Non-Apple clang (shouldn't happen with CLT but handle it)
            parts = line.split("clang version ")
            if len(parts) > 1:
                result["version"] = parts[1].split(" ")[0]
            break

    result["ok"] = True
    return result


def _verify_git():
    """Verify git is working.

    Returns:
        dict: {ok: bool, path: str, version: str}
    """

    result = {
        "ok": False,
        "path": "",
        "version": "",
    }

    git_path = fs.which("git")
    if not git_path:
        warn("git not found in PATH")
        return result

    result["path"] = git_path

    version_result = shell.exec(
        command = "git --version",
        allowed_commands = ["git"],
    )

    if not version_result.ok:
        warn("git --version failed: " + version_result.stderr)
        return result

    # Parse "git version 2.39.3 (Apple Git-145)"
    output = version_result.stdout.strip()
    if output.startswith("git version "):
        result["version"] = output.replace("git version ", "")

    result["ok"] = True
    return result


def _verify_make():
    """Verify make is working.

    Returns:
        dict: {ok: bool, path: str, version: str}
    """

    result = {
        "ok": False,
        "path": "",
        "version": "",
    }

    make_path = fs.which("make")
    if not make_path:
        warn("make not found in PATH")
        return result

    result["path"] = make_path

    version_result = shell.exec(
        command = "make --version",
        allowed_commands = ["make"],
    )

    if not version_result.ok:
        warn("make --version failed: " + version_result.stderr)
        return result

    # Parse "GNU Make 3.81"
    output = version_result.stdout
    first_line = output.split("\n")[0]
    result["version"] = first_line

    result["ok"] = True
    return result


def _verify_linker():
    """Verify the linker (ld) is working.

    Returns:
        dict: {ok: bool, path: str, version: str}
    """

    result = {
        "ok": False,
        "path": "",
        "version": "",
    }

    ld_path = fs.which("ld")
    if not ld_path:
        warn("ld (linker) not found in PATH")
        return result

    result["path"] = ld_path

    version_result = shell.exec(
        command = "ld -v 2>&1 || true",
        allowed_commands = ["ld"],
    )

    # ld outputs to stderr by default
    output = version_result.stdout + version_result.stderr
    if output:
        # Parse "@(#)PROGRAM:ld  PROJECT:dyld-1015.7"
        result["version"] = output.strip().split("\n")[0]

    # ld -v returns non-zero even when working, so just check path exists
    result["ok"] = fs.exists(ld_path)
    return result


def _verify_sdk():
    """Verify SDK is available.

    Returns:
        str: SDK path
    """

    result = shell.exec(
        command = "xcrun --show-sdk-path",
        allowed_commands = ["xcrun"],
    )

    if not result.ok:
        warn("Could not determine SDK path: " + result.stderr)
        # Try fallback
        sdk_path = _CLT_PATH + "/SDKs/MacOSX.sdk"
        if fs.exists(sdk_path):
            return sdk_path
        return ""

    sdk_path = result.stdout.strip()

    if not fs.exists(sdk_path):
        warn("SDK path does not exist: " + sdk_path)
        return ""

    # Verify SDK has headers
    headers_path = sdk_path + "/usr/include"
    if not fs.exists(headers_path):
        warn("SDK headers not found at: " + headers_path)

    return sdk_path


def _verify_compilation():
    """The ultimate test: compile and run a test program.

    This verifies the entire toolchain is functional:
    - Preprocessor can find headers
    - Compiler can generate code
    - Linker can produce executables
    - Runtime can execute the binary

    Returns:
        bool: True if compilation test passed
    """

    note("Running compilation verification test...")

    test_dir = "/tmp/lore-xcode-clt-test"
    test_c = test_dir + "/test.c"
    test_bin = test_dir + "/test"

    # Create test directory
    fs.mkdir(test_dir, parents = True)

    # Write a simple test program that exercises:
    # - Standard headers
    # - System calls
    # - String operations
    # - Exit codes
    test_code = """/* Lore CLT verification test */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
    /* Test stdio */
    printf("CLT verification: ");

    /* Test string operations */
    const char *msg = "PASS";
    if (strlen(msg) != 4) {
        printf("FAIL (string)\\n");
        return 1;
    }

    /* Test system calls */
    if (getpid() <= 0) {
        printf("FAIL (syscall)\\n");
        return 1;
    }

    printf("%s\\n", msg);
    return 0;
}
"""

    fs.write(test_c, test_code)

    # Compile the test program
    compile_result = shell.exec(
        command = "clang -o " + test_bin + " " + test_c + " -Wall -Werror",
        allowed_commands = ["clang"],
    )

    if not compile_result.ok:
        warn("Compilation failed: " + compile_result.stderr)
        _cleanup_test(test_dir)
        return False

    # Run the test program
    run_result = shell.exec(
        command = test_bin,
        allowed_commands = [test_bin],
    )

    # Cleanup
    _cleanup_test(test_dir)

    if not run_result.ok:
        warn("Test execution failed: " + run_result.stderr)
        return False

    if "PASS" not in run_result.stdout:
        warn("Test output unexpected: " + run_result.stdout)
        return False

    note("Compilation test passed")
    return True


def _cleanup_test(test_dir):
    """Clean up test files."""

    if fs.exists(test_dir):
        shell.exec(
            command = "rm -rf " + test_dir,
            allowed_commands = ["rm"],
        )


def _verify_rosetta():
    """Verify Rosetta 2 is working on Apple Silicon.

    Returns:
        dict: {ok: bool, version: str}
    """

    result = {
        "ok": False,
        "version": "",
    }

    # Try to run an x86_64 command via Rosetta
    run_result = shell.exec(
        command = "arch -x86_64 /usr/bin/true",
        allowed_commands = ["arch"],
    )

    if run_result.ok:
        result["ok"] = True
        result["version"] = "installed"
        note("Rosetta 2 verification passed")
    else:
        warn("Rosetta 2 verification failed: " + run_result.stderr)

    return result
