#!/usr/bin/env python3
"""
Validate and import a Godot project.

Usage:
    python validate_project.py --project ./my-game
    python validate_project.py --project ./my-game --check-scripts
"""

import argparse
import subprocess
import sys
import re
from pathlib import Path


def find_godot() -> str:
    """Find the Godot executable."""
    import os
    candidates = [
        "godot",
        "godot4",
        os.environ.get("GODOT", ""),
        os.environ.get("GODOT4", ""),
    ]

    for candidate in candidates:
        if candidate and subprocess.run(
            ["which", candidate],
            capture_output=True
        ).returncode == 0:
            return candidate

    print("ERROR: Godot executable not found.")
    sys.exit(1)


def import_project(project_path: Path, godot: str) -> tuple[bool, str]:
    """Import project resources."""
    print("Importing project resources...")

    result = subprocess.run(
        [godot, "--headless", "--import", "--path", str(project_path)],
        capture_output=True,
        text=True,
        timeout=120,
    )

    output = result.stdout + result.stderr

    # Check for errors (but ignore common warnings)
    error_patterns = [
        r"SCRIPT ERROR",
        r"ERROR:",
        r"Failed to load",
        r"Cannot open file",
    ]

    has_errors = False
    for pattern in error_patterns:
        if re.search(pattern, output, re.IGNORECASE):
            has_errors = True
            break

    return (not has_errors, output)


def validate_scripts(project_path: Path, godot: str) -> tuple[bool, list[str]]:
    """Check all GDScript files for syntax errors."""
    print("Validating GDScript files...")

    errors = []
    scripts = list(project_path.rglob("*.gd"))

    # Skip addons directory for validation
    scripts = [s for s in scripts if "addons" not in str(s)]

    for script in scripts:
        rel_path = script.relative_to(project_path)
        result = subprocess.run(
            [
                godot, "--headless",
                "--path", str(project_path),
                "--check-only",
                "--script", f"res://{rel_path}",
            ],
            capture_output=True,
            text=True,
            timeout=30,
        )

        output = result.stdout + result.stderr

        if "error" in output.lower() or result.returncode != 0:
            errors.append(f"{rel_path}: {output.strip()}")
        else:
            print(f"  ✓ {rel_path}")

    return (len(errors) == 0, errors)


def check_project_structure(project_path: Path) -> tuple[bool, list[str]]:
    """Verify required project files exist."""
    print("Checking project structure...")

    issues = []

    # Required files
    if not (project_path / "project.godot").exists():
        issues.append("Missing project.godot")

    # Check for main scene
    project_godot = project_path / "project.godot"
    if project_godot.exists():
        content = project_godot.read_text()
        if 'run/main_scene="' not in content:
            issues.append("No main scene configured in project.godot")

    # Check for test directory (optional but recommended)
    if not (project_path / "test").exists():
        print("  ⚠ No test/ directory found (optional)")

    # Check for GdUnit4
    gdunit_path = project_path / "addons" / "gdUnit4"
    if not gdunit_path.exists():
        print("  ⚠ GdUnit4 not installed (optional)")

    return (len(issues) == 0, issues)


def main():
    parser = argparse.ArgumentParser(
        description="Validate and import a Godot project"
    )

    parser.add_argument(
        "--project", "-p",
        required=True,
        help="Path to Godot project directory"
    )
    parser.add_argument(
        "--check-scripts", "-c",
        action="store_true",
        help="Validate all GDScript files"
    )
    parser.add_argument(
        "--import-only", "-i",
        action="store_true",
        help="Only import project, skip other checks"
    )

    args = parser.parse_args()

    project_path = Path(args.project).resolve()

    if not project_path.exists():
        print(f"ERROR: Project directory not found: {project_path}")
        sys.exit(1)

    godot = find_godot()
    all_passed = True

    print(f"Validating project: {project_path}")
    print("=" * 60)

    # Structure check
    if not args.import_only:
        passed, issues = check_project_structure(project_path)
        if not passed:
            all_passed = False
            for issue in issues:
                print(f"  ✗ {issue}")
        else:
            print("  ✓ Project structure OK")

    # Import
    passed, output = import_project(project_path, godot)
    if not passed:
        all_passed = False
        print("  ✗ Import failed")
        print(output)
    else:
        print("  ✓ Project imported successfully")

    # Script validation
    if args.check_scripts and not args.import_only:
        passed, errors = validate_scripts(project_path, godot)
        if not passed:
            all_passed = False
            print("  ✗ Script validation failed:")
            for error in errors:
                print(f"    {error}")
        else:
            print("  ✓ All scripts valid")

    print("=" * 60)
    if all_passed:
        print("VALIDATION PASSED")
        sys.exit(0)
    else:
        print("VALIDATION FAILED")
        sys.exit(1)


if __name__ == "__main__":
    main()
