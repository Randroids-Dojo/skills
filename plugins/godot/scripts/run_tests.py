#!/usr/bin/env python3
"""
Run GdUnit4 tests for a Godot project.

Usage:
    python run_tests.py --project ./my-game
    python run_tests.py --project ./my-game --filter "player"
    python run_tests.py --project ./my-game --report ./reports
"""

import argparse
import subprocess
import sys
import os
from pathlib import Path


def find_godot() -> str:
    """Find the Godot executable."""
    # Check common locations
    candidates = [
        "godot",
        "godot4",
        os.environ.get("GODOT", ""),
        os.environ.get("GODOT4", ""),
        "/usr/local/bin/godot",
        "/usr/bin/godot",
    ]

    for candidate in candidates:
        if candidate and subprocess.run(
            ["which", candidate],
            capture_output=True
        ).returncode == 0:
            return candidate

    print("ERROR: Godot executable not found.")
    print("Set GODOT or GODOT4 environment variable or ensure 'godot' is in PATH.")
    sys.exit(1)


def run_tests(
    project: str,
    filter_pattern: str = None,
    report_dir: str = None,
    verbose: bool = False,
    timeout: int = 300,
) -> int:
    """
    Run GdUnit4 tests.

    Args:
        project: Path to Godot project directory
        filter_pattern: Optional filter for test names
        report_dir: Optional directory for JUnit XML reports
        verbose: Enable verbose output
        timeout: Test timeout in seconds

    Returns:
        Exit code (0 = success, non-zero = failure)
    """
    project_path = Path(project).resolve()

    if not project_path.exists():
        print(f"ERROR: Project directory not found: {project_path}")
        return 1

    if not (project_path / "project.godot").exists():
        print(f"ERROR: No project.godot found in: {project_path}")
        return 1

    gdunit_tool = project_path / "addons" / "gdUnit4" / "bin" / "GdUnitCmdTool.gd"
    if not gdunit_tool.exists():
        print(f"ERROR: GdUnit4 not found at: {gdunit_tool}")
        print("Install GdUnit4 via Asset Library or clone from GitHub:")
        print("  git clone https://github.com/MikeSchulze/gdUnit4.git addons/gdUnit4")
        return 1

    godot = find_godot()

    # Build command
    cmd = [
        godot,
        "--headless",
        "--path", str(project_path),
        "-s", "res://addons/gdUnit4/bin/GdUnitCmdTool.gd",
        "--run-tests",
    ]

    if filter_pattern:
        cmd.extend(["--add", filter_pattern])

    if report_dir:
        report_path = Path(report_dir).resolve()
        report_path.mkdir(parents=True, exist_ok=True)
        cmd.extend(["--report-directory", str(report_path)])

    if verbose:
        print(f"Running: {' '.join(cmd)}")

    print(f"Running GdUnit4 tests in: {project_path}")
    print("-" * 60)

    try:
        result = subprocess.run(
            cmd,
            cwd=project_path,
            timeout=timeout,
        )
        return result.returncode
    except subprocess.TimeoutExpired:
        print(f"ERROR: Tests timed out after {timeout} seconds")
        return 1
    except KeyboardInterrupt:
        print("\nTests interrupted by user")
        return 130


def main():
    parser = argparse.ArgumentParser(
        description="Run GdUnit4 tests for a Godot project",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s --project ./my-game
  %(prog)s --project ./my-game --filter "test_player"
  %(prog)s --project ./my-game --report ./reports --verbose
        """
    )

    parser.add_argument(
        "--project", "-p",
        required=True,
        help="Path to Godot project directory"
    )
    parser.add_argument(
        "--filter", "-f",
        help="Filter tests by pattern"
    )
    parser.add_argument(
        "--report", "-r",
        help="Directory for JUnit XML reports"
    )
    parser.add_argument(
        "--timeout", "-t",
        type=int,
        default=300,
        help="Test timeout in seconds (default: 300)"
    )
    parser.add_argument(
        "--verbose", "-v",
        action="store_true",
        help="Enable verbose output"
    )

    args = parser.parse_args()

    exit_code = run_tests(
        project=args.project,
        filter_pattern=args.filter,
        report_dir=args.report,
        verbose=args.verbose,
        timeout=args.timeout,
    )

    sys.exit(exit_code)


if __name__ == "__main__":
    main()
