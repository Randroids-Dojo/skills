#!/usr/bin/env python3

import argparse
import shlex
import subprocess


def build_command(args: argparse.Namespace):
    cmd = [args.exe]

    if args.uproject:
        cmd.append(args.uproject)

    if args.map:
        cmd.append(args.map)

    if args.rc_enable:
        cmd.extend(["-RCWebControlEnable", "-RCWebInterfaceEnable"])

    exec_cmds = []
    if args.start_rc:
        exec_cmds.append("WebControl.StartServer")
    exec_cmds.extend(args.exec_cmd)

    if exec_cmds:
        cmd.append("-ExecCmds=" + ";".join(exec_cmds))

    if args.extra_arg:
        cmd.extend(args.extra_arg)

    return cmd


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Launch Unreal with optional Remote Control flags."
    )
    parser.add_argument(
        "--exe",
        required=True,
        help="Path to UnrealEditor or packaged executable.",
    )
    parser.add_argument("--uproject", help="Path to .uproject (editor only).")
    parser.add_argument("--map", help="Map path passed as a positional arg.")
    parser.add_argument(
        "--rc-enable",
        action="store_true",
        help="Add RC flags for packaged builds.",
    )
    parser.add_argument(
        "--start-rc",
        dest="start_rc",
        action="store_true",
        default=True,
        help="Add WebControl.StartServer to ExecCmds.",
    )
    parser.add_argument(
        "--no-start-rc",
        dest="start_rc",
        action="store_false",
        help="Do not add WebControl.StartServer.",
    )
    parser.add_argument(
        "--exec-cmd",
        action="append",
        default=[],
        help="Additional ExecCmds (repeatable).",
    )
    parser.add_argument(
        "--extra-arg",
        action="append",
        default=[],
        help="Extra args passed through (repeatable).",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print the command and exit.",
    )
    parser.add_argument(
        "--wait",
        action="store_true",
        help="Wait for the Unreal process to exit.",
    )

    args = parser.parse_args()
    cmd = build_command(args)
    cmd_text = shlex.join(cmd)

    if args.dry_run:
        print(cmd_text)
        return 0

    print(cmd_text)
    process = subprocess.Popen(cmd)

    if args.wait:
        return process.wait()

    print(f"Launched Unreal (pid={process.pid}).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
