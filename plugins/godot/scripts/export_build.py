#!/usr/bin/env python3
"""
Export Godot projects for various platforms.

Usage:
    python export_build.py --project ./my-game --preset Web --output ./build
    python export_build.py --project ./my-game --preset Web --output ./build/index.html
"""

import argparse
import subprocess
import sys
import os
from pathlib import Path


def find_godot() -> str:
    """Find the Godot executable."""
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
    print("Set GODOT or GODOT4 environment variable or ensure 'godot' is in PATH.")
    sys.exit(1)


def check_export_templates(godot: str) -> bool:
    """Check if export templates are installed."""
    # Get Godot version
    result = subprocess.run(
        [godot, "--version"],
        capture_output=True,
        text=True
    )
    version = result.stdout.strip().split('.')[0:2]
    version_str = '.'.join(version)

    # Check common template locations
    home = Path.home()
    template_paths = [
        home / ".local/share/godot/export_templates" / version_str,
        home / ".godot/export_templates" / version_str,
        home / "Library/Application Support/Godot/export_templates" / version_str,
    ]

    for path in template_paths:
        if path.exists():
            return True

    return False


def check_export_presets(project_path: Path) -> list[str]:
    """Get available export presets from project."""
    presets_file = project_path / "export_presets.cfg"

    if not presets_file.exists():
        return []

    presets = []
    content = presets_file.read_text()

    for line in content.split('\n'):
        if line.startswith('name="'):
            preset_name = line.split('"')[1]
            presets.append(preset_name)

    return presets


def export_project(
    project: str,
    preset: str,
    output: str,
    debug: bool = False,
    verbose: bool = False,
) -> int:
    """
    Export a Godot project.

    Args:
        project: Path to Godot project directory
        preset: Export preset name (must exist in export_presets.cfg)
        output: Output path for the exported build
        debug: Use debug export instead of release
        verbose: Enable verbose output

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

    # Check export presets
    available_presets = check_export_presets(project_path)
    if not available_presets:
        print("ERROR: No export_presets.cfg found in project.")
        print("Create one using Godot Editor: Project → Export → Add...")
        return 1

    if preset not in available_presets:
        print(f"ERROR: Preset '{preset}' not found.")
        print(f"Available presets: {', '.join(available_presets)}")
        return 1

    godot = find_godot()

    # Check export templates
    if not check_export_templates(godot):
        print("WARNING: Export templates may not be installed.")
        print("Install via: Godot Editor → Editor → Manage Export Templates")

    # Prepare output path
    output_path = Path(output).resolve()
    output_path.parent.mkdir(parents=True, exist_ok=True)

    # Build command
    export_flag = "--export-debug" if debug else "--export-release"
    cmd = [
        godot,
        "--headless",
        "--path", str(project_path),
        export_flag, preset,
        str(output_path),
    ]

    if verbose:
        print(f"Running: {' '.join(cmd)}")

    print(f"Exporting '{preset}' build...")
    print(f"  Project: {project_path}")
    print(f"  Output: {output_path}")
    print("-" * 60)

    try:
        result = subprocess.run(
            cmd,
            cwd=project_path,
            timeout=300,  # 5 minute timeout
        )

        if result.returncode == 0 and output_path.exists():
            print("-" * 60)
            print(f"Export successful!")

            # Show output files
            if output_path.is_dir():
                files = list(output_path.rglob("*"))
                print(f"Files created: {len(files)}")
            else:
                size = output_path.stat().st_size / 1024 / 1024
                print(f"File size: {size:.2f} MB")

            return 0
        else:
            print("ERROR: Export failed or output not created.")
            return 1

    except subprocess.TimeoutExpired:
        print("ERROR: Export timed out after 5 minutes")
        return 1
    except KeyboardInterrupt:
        print("\nExport interrupted by user")
        return 130


def main():
    parser = argparse.ArgumentParser(
        description="Export Godot projects for various platforms",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s --project ./my-game --preset Web --output ./build/index.html
  %(prog)s --project ./my-game --preset "Windows Desktop" --output ./dist/game.exe
  %(prog)s --project ./my-game --preset Linux --output ./dist/game.x86_64 --debug
        """
    )

    parser.add_argument(
        "--project", "-p",
        required=True,
        help="Path to Godot project directory"
    )
    parser.add_argument(
        "--preset", "-e",
        required=True,
        help="Export preset name (from export_presets.cfg)"
    )
    parser.add_argument(
        "--output", "-o",
        required=True,
        help="Output path for the exported build"
    )
    parser.add_argument(
        "--debug", "-d",
        action="store_true",
        help="Create debug build instead of release"
    )
    parser.add_argument(
        "--verbose", "-v",
        action="store_true",
        help="Enable verbose output"
    )
    parser.add_argument(
        "--list-presets", "-l",
        action="store_true",
        help="List available export presets and exit"
    )

    args = parser.parse_args()

    project_path = Path(args.project).resolve()

    if args.list_presets:
        presets = check_export_presets(project_path)
        if presets:
            print("Available export presets:")
            for preset in presets:
                print(f"  - {preset}")
        else:
            print("No export presets found.")
            print("Create one using Godot Editor: Project → Export → Add...")
        return

    exit_code = export_project(
        project=args.project,
        preset=args.preset,
        output=args.output,
        debug=args.debug,
        verbose=args.verbose,
    )

    sys.exit(exit_code)


if __name__ == "__main__":
    main()
