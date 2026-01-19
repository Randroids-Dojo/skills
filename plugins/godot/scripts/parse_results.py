#!/usr/bin/env python3
"""
Parse GdUnit4 JUnit XML test results.

Usage:
    python parse_results.py ./reports
    python parse_results.py ./reports --format summary
    python parse_results.py ./reports --format json
"""

import argparse
import json
import sys
import xml.etree.ElementTree as ET
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import List, Optional


@dataclass
class TestCase:
    name: str
    classname: str
    time: float
    status: str  # passed, failed, skipped, error
    message: Optional[str] = None
    output: Optional[str] = None


@dataclass
class TestSuite:
    name: str
    tests: int
    failures: int
    errors: int
    skipped: int
    time: float
    testcases: List[TestCase]


@dataclass
class TestResults:
    suites: List[TestSuite]
    total_tests: int
    total_failures: int
    total_errors: int
    total_skipped: int
    total_time: float
    success: bool


def parse_junit_xml(xml_path: Path) -> Optional[TestSuite]:
    """Parse a single JUnit XML file."""
    try:
        tree = ET.parse(xml_path)
        root = tree.getroot()

        # Handle both <testsuite> and <testsuites> root elements
        if root.tag == "testsuites":
            suites = root.findall("testsuite")
        elif root.tag == "testsuite":
            suites = [root]
        else:
            return None

        all_testcases = []

        for suite in suites:
            for testcase in suite.findall("testcase"):
                name = testcase.get("name", "unknown")
                classname = testcase.get("classname", "unknown")
                time = float(testcase.get("time", 0))

                # Determine status
                failure = testcase.find("failure")
                error = testcase.find("error")
                skipped = testcase.find("skipped")

                if failure is not None:
                    status = "failed"
                    message = failure.get("message", "")
                    output = failure.text
                elif error is not None:
                    status = "error"
                    message = error.get("message", "")
                    output = error.text
                elif skipped is not None:
                    status = "skipped"
                    message = skipped.get("message", "")
                    output = None
                else:
                    status = "passed"
                    message = None
                    output = None

                all_testcases.append(TestCase(
                    name=name,
                    classname=classname,
                    time=time,
                    status=status,
                    message=message,
                    output=output,
                ))

        if suites:
            suite = suites[0]
            return TestSuite(
                name=suite.get("name", xml_path.stem),
                tests=int(suite.get("tests", len(all_testcases))),
                failures=int(suite.get("failures", 0)),
                errors=int(suite.get("errors", 0)),
                skipped=int(suite.get("skipped", 0)),
                time=float(suite.get("time", 0)),
                testcases=all_testcases,
            )

    except ET.ParseError as e:
        print(f"WARNING: Failed to parse {xml_path}: {e}", file=sys.stderr)
        return None

    return None


def parse_results_directory(report_dir: Path) -> TestResults:
    """Parse all JUnit XML files in a directory."""
    suites = []

    for xml_file in report_dir.glob("**/*.xml"):
        suite = parse_junit_xml(xml_file)
        if suite:
            suites.append(suite)

    total_tests = sum(s.tests for s in suites)
    total_failures = sum(s.failures for s in suites)
    total_errors = sum(s.errors for s in suites)
    total_skipped = sum(s.skipped for s in suites)
    total_time = sum(s.time for s in suites)

    return TestResults(
        suites=suites,
        total_tests=total_tests,
        total_failures=total_failures,
        total_errors=total_errors,
        total_skipped=total_skipped,
        total_time=total_time,
        success=(total_failures == 0 and total_errors == 0),
    )


def format_summary(results: TestResults) -> str:
    """Format results as human-readable summary."""
    lines = []
    lines.append("=" * 60)
    lines.append("TEST RESULTS SUMMARY")
    lines.append("=" * 60)
    lines.append("")

    # Overall stats
    passed = results.total_tests - results.total_failures - results.total_errors - results.total_skipped
    lines.append(f"Total:    {results.total_tests} tests")
    lines.append(f"Passed:   {passed}")
    lines.append(f"Failed:   {results.total_failures}")
    lines.append(f"Errors:   {results.total_errors}")
    lines.append(f"Skipped:  {results.total_skipped}")
    lines.append(f"Time:     {results.total_time:.2f}s")
    lines.append("")

    # Show failures and errors
    for suite in results.suites:
        for tc in suite.testcases:
            if tc.status == "failed":
                lines.append(f"FAILED: {tc.classname}::{tc.name}")
                if tc.message:
                    lines.append(f"  {tc.message}")
            elif tc.status == "error":
                lines.append(f"ERROR: {tc.classname}::{tc.name}")
                if tc.message:
                    lines.append(f"  {tc.message}")

    lines.append("")
    lines.append("=" * 60)
    if results.success:
        lines.append("ALL TESTS PASSED")
    else:
        lines.append("TESTS FAILED")
    lines.append("=" * 60)

    return "\n".join(lines)


def format_json(results: TestResults) -> str:
    """Format results as JSON."""
    return json.dumps(asdict(results), indent=2)


def format_markdown(results: TestResults) -> str:
    """Format results as Markdown table."""
    lines = []
    lines.append("## Test Results")
    lines.append("")

    passed = results.total_tests - results.total_failures - results.total_errors - results.total_skipped
    status_emoji = "✅" if results.success else "❌"

    lines.append(f"**Status**: {status_emoji} {'Passed' if results.success else 'Failed'}")
    lines.append("")
    lines.append("| Metric | Count |")
    lines.append("|--------|-------|")
    lines.append(f"| Total | {results.total_tests} |")
    lines.append(f"| Passed | {passed} |")
    lines.append(f"| Failed | {results.total_failures} |")
    lines.append(f"| Errors | {results.total_errors} |")
    lines.append(f"| Skipped | {results.total_skipped} |")
    lines.append(f"| Time | {results.total_time:.2f}s |")

    if not results.success:
        lines.append("")
        lines.append("### Failures")
        lines.append("")
        for suite in results.suites:
            for tc in suite.testcases:
                if tc.status in ("failed", "error"):
                    lines.append(f"- **{tc.classname}::{tc.name}**: {tc.message or 'No message'}")

    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(
        description="Parse GdUnit4 JUnit XML test results"
    )

    parser.add_argument(
        "report_dir",
        help="Directory containing JUnit XML files"
    )
    parser.add_argument(
        "--format", "-f",
        choices=["summary", "json", "markdown"],
        default="summary",
        help="Output format (default: summary)"
    )
    parser.add_argument(
        "--exit-code", "-e",
        action="store_true",
        help="Exit with non-zero code if tests failed"
    )

    args = parser.parse_args()

    report_path = Path(args.report_dir)
    if not report_path.exists():
        print(f"ERROR: Report directory not found: {report_path}")
        sys.exit(1)

    results = parse_results_directory(report_path)

    if args.format == "summary":
        print(format_summary(results))
    elif args.format == "json":
        print(format_json(results))
    elif args.format == "markdown":
        print(format_markdown(results))

    if args.exit_code and not results.success:
        sys.exit(1)


if __name__ == "__main__":
    main()
