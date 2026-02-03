#!/usr/bin/env python3

import argparse
import json
import time
import urllib.error
import urllib.request


def http_get(url: str, timeout: float) -> bytes:
    req = urllib.request.Request(url, method="GET")
    with urllib.request.urlopen(req, timeout=timeout) as response:
        return response.read()


def http_put_json(url: str, payload: dict, timeout: float) -> dict:
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        url,
        data=data,
        method="PUT",
        headers={"Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req, timeout=timeout) as response:
        body = response.read().decode("utf-8")
    try:
        return json.loads(body)
    except json.JSONDecodeError:
        return {"raw": body}


def wait_for_info(host: str, port: int, timeout: float, interval: float) -> None:
    url = f"http://{host}:{port}/remote/info"
    deadline = time.time() + timeout
    while True:
        try:
            http_get(url, timeout=interval)
            return
        except (urllib.error.URLError, TimeoutError):
            if time.time() >= deadline:
                raise TimeoutError(f"Remote Control not ready at {url}")
            time.sleep(interval)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Wait for Unreal Remote Control and optionally call Ping."
    )
    parser.add_argument("--host", default="127.0.0.1", help="Remote Control host.")
    parser.add_argument("--port", type=int, default=30010, help="Remote Control port.")
    parser.add_argument(
        "--timeout", type=float, default=30.0, help="Timeout in seconds."
    )
    parser.add_argument("--interval", type=float, default=0.5, help="Poll interval.")
    parser.add_argument("--object-path", help="Automation actor object path.")
    parser.add_argument(
        "--function",
        default="Ping",
        help="Function to call on the object path.",
    )
    parser.add_argument(
        "--params",
        default="{}",
        help="JSON parameters for the function call.",
    )
    args = parser.parse_args()

    wait_for_info(args.host, args.port, args.timeout, args.interval)
    print("Remote Control ready.")

    if not args.object_path:
        return 0

    try:
        params = json.loads(args.params)
    except json.JSONDecodeError as exc:
        raise SystemExit(f"Invalid --params JSON: {exc}")

    call_url = f"http://{args.host}:{args.port}/remote/object/call"
    payload = {
        "objectPath": args.object_path,
        "functionName": args.function,
        "parameters": params,
    }
    response = http_put_json(call_url, payload, timeout=args.timeout)
    print(json.dumps(response, indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
