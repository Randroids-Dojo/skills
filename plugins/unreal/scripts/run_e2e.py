#!/usr/bin/env python3

import argparse
import subprocess
import sys
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Launch Unreal, wait for Remote Control, then run pytest."
    )
    parser.add_argument("--ue-exe", required=True, help="Path to Unreal executable.")
    parser.add_argument("--uproject", help="Path to .uproject (editor only).")
    parser.add_argument("--map", help="Map path passed as a positional arg.")
    parser.add_argument(
        "--rc-enable",
        action="store_true",
        help="Add RC flags for packaged builds.",
    )
    parser.add_argument("--rc-host", default="127.0.0.1")
    parser.add_argument("--rc-port", type=int, default=30010)
    parser.add_argument("--object-path", help="Automation actor object path.")
    parser.add_argument("--ping-function", default="Ping")
    parser.add_argument("--timeout", type=float, default=60.0)
    parser.add_argument("--tests", default="tests", help="Pytest path or node id.")
    parser.add_argument(
        "--pytest-arg",
        action="append",
        default=[],
        help="Extra pytest args (repeatable).",
    )
    parser.add_argument(
        "--keep-alive",
        action="store_true",
        help="Do not terminate Unreal after tests.",
    )
    args = parser.parse_args()

    script_dir = Path(__file__).resolve().parent
    launch_cmd = [
        sys.executable,
        str(script_dir / "ue_launch.py"),
        "--exe",
        args.ue_exe,
    ]
    if args.uproject:
        launch_cmd.extend(["--uproject", args.uproject])
    if args.map:
        launch_cmd.extend(["--map", args.map])
    if args.rc_enable:
        launch_cmd.append("--rc-enable")

    unreal_process = subprocess.Popen(launch_cmd)

    wait_cmd = [
        sys.executable,
        str(script_dir / "rc_wait_ready.py"),
        "--host",
        args.rc_host,
        "--port",
        str(args.rc_port),
        "--timeout",
        str(args.timeout),
    ]
    if args.object_path:
        wait_cmd.extend(["--object-path", args.object_path])
        wait_cmd.extend(["--function", args.ping_function])

    try:
        subprocess.check_call(wait_cmd)
    except subprocess.CalledProcessError:
        unreal_process.terminate()
        return 1

    pytest_cmd = ["pytest", args.tests, *args.pytest_arg]
    exit_code = subprocess.call(pytest_cmd)

    if not args.keep_alive:
        unreal_process.terminate()
        try:
            unreal_process.wait(timeout=10)
        except subprocess.TimeoutExpired:
            unreal_process.kill()

    return exit_code


if __name__ == "__main__":
    raise SystemExit(main())
