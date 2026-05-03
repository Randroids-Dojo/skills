#!/usr/bin/env bash
#
# spiral audit: diff a target repo against the canonical spiral scaffold.
#
# Usage:
#   bash audit.sh [path-to-repo]
#
# Prints a remediation checklist. Does not modify anything.

set -uo pipefail

TARGET_DIR="${1:-$(pwd)}"

if [[ ! -d "${TARGET_DIR}" ]]; then
  echo "Error: ${TARGET_DIR} is not a directory." >&2
  exit 1
fi

cd "${TARGET_DIR}"

findings=()
add_finding() {
  findings+=("$1")
}

# Check 1: missing canonical files
canonical=(
  "AGENTS.md"
  "CLAUDE.md"
  "docs/IMPLEMENTATION_PLAN.md"
  "docs/WORKING_AGREEMENT.md"
  "docs/gdd/README.md"
  "docs/GDD_COVERAGE.json"
  "docs/PROGRESS_LOG.md"
  "docs/OPEN_QUESTIONS.md"
  "docs/FOLLOWUPS.md"
  "docs/PLAYTEST.md"
  "docs/FUN_FACTOR_AUDIT.md"
  ".claude/rules/slice-discipline.md"
  ".claude/rules/ledger-append-only.md"
  ".claude/rules/gdd-build-log.md"
)

# Codex symlinks: per-directory AGENTS.md aliases for the rules.
codex_symlinks=(
  "docs/AGENTS.md:.claude/rules/ledger-append-only.md"
  "docs/gdd/AGENTS.md:.claude/rules/gdd-build-log.md"
)

for f in "${canonical[@]}"; do
  if [[ ! -e "${f}" ]]; then
    add_finding "[MISSING] ${f} does not exist. Run /spiral init or copy the template manually."
  fi
done

# Verify Codex symlinks point to the right targets.
for entry in "${codex_symlinks[@]}"; do
  link="${entry%%:*}"
  target="${entry##*:}"
  if [[ -L "${link}" ]]; then
    actual=$(readlink "${link}")
    expected_suffix="${target}"
    case "${actual}" in
      *"${expected_suffix##*/}") : ;;
      *) add_finding "[CODEX] ${link} is a symlink but points to '${actual}', expected to resolve to ${target}. Codex's AGENTS.md walk may load the wrong content." ;;
    esac
  elif [[ -f "${link}" ]]; then
    add_finding "[CODEX] ${link} exists as a regular file, not a symlink to ${target}. Codex will read this file but it will drift from ${target}. Replace with: ln -sf <relative-path>/${target} ${link}"
  else
    add_finding "[CODEX] ${link} is missing. Without it, Codex cannot pick up ${target} on its root-down AGENTS.md walk when working in $(dirname "${link}")/."
  fi
done

# Check 2: monolith GDD
if [[ -f "docs/GDD.md" && ! -d "docs/gdd" ]]; then
  add_finding "[ANTI-PATTERN] docs/GDD.md exists as a single file. Split into docs/gdd/<n>-<title>.md per requirement. A monolith GDD makes coverage rows chapter-granular by default, which is the Flatline failure mode."
fi

# Check 3: chapter-granular coverage
if [[ -f "docs/GDD_COVERAGE.json" ]]; then
  # Try to count rows. Prefer python over jq for portability.
  rows=$(python3 -c "
import json, sys
try:
    with open('docs/GDD_COVERAGE.json') as f:
        data = json.load(f)
    if isinstance(data, dict):
        for key in ('rows', 'sections', 'requirements', 'items', 'coverage'):
            if key in data and isinstance(data[key], list):
                print(len(data[key]))
                sys.exit(0)
        print(0)
    elif isinstance(data, list):
        print(len(data))
    else:
        print(0)
except Exception:
    print(-1)
" 2>/dev/null)

  if [[ "${rows}" == "-1" ]]; then
    add_finding "[WARN] docs/GDD_COVERAGE.json could not be parsed as JSON. Fix the file."
  elif [[ "${rows}" -lt 1 ]]; then
    add_finding "[WARN] docs/GDD_COVERAGE.json has 0 rows. Add atomic-granularity requirement rows."
  else
    # Heuristic: project age in days, inferred from oldest commit
    age_days=$(git log --reverse --pretty=format:%ct 2>/dev/null | head -1 | awk -v now="$(date +%s)" '{ if ($0 != "") print int((now - $0) / 86400) }')
    if [[ -n "${age_days}" && "${age_days}" -gt 0 ]]; then
      project_weeks=$(( (age_days + 6) / 7 ))
      [[ "${project_weeks}" -lt 1 ]] && project_weeks=1
      # Threshold: 14 rows per project-week. Calibrated against case studies:
      # - Flatline 11 rows / 3 days (threshold 14) → flags (correct).
      # - VibeRacer 12 rows / 14 days (threshold 28) → flags. Acceptable: VibeRacer survived only because §18 of its GDD was an explicit out-of-scope fence; the audit is right to flag the at-risk shape.
      # - VibeGear2 102 rows / 7 days (threshold 14) → clean.
      threshold=$(( project_weeks * 14 ))
      if [[ "${rows}" -lt "${threshold}" ]]; then
        add_finding "[ANTI-PATTERN] docs/GDD_COVERAGE.json has ${rows} rows for a ~${age_days}-day-old project (~${project_weeks} weeks). Heuristic threshold is ${threshold} (14 rows / project-week). This is likely chapter-granular coverage. The Flatline failure mode is rows that flip to 'done' once any code lands. Split into requirement-granular rows."
      fi
    fi
  fi
fi

# Check 4: missing qualitative gate
if [[ ! -f "docs/PLAYTEST.md" ]]; then
  add_finding "[ANTI-FLATLINE] docs/PLAYTEST.md is missing. Without the second qualitative gate, the loop terminates when systems exist instead of when the product is good."
fi
if [[ ! -f "docs/FUN_FACTOR_AUDIT.md" ]]; then
  add_finding "[ANTI-FLATLINE] docs/FUN_FACTOR_AUDIT.md is missing. Without a periodic gap audit, the backlog will not surface the experience-level work that coverage rows cannot catch."
fi

# Check 5: stale progress log
if [[ -f "docs/PROGRESS_LOG.md" ]]; then
  newest=$(grep -E '^## [0-9]{4}-[0-9]{2}-[0-9]{2}' docs/PROGRESS_LOG.md | head -1 | sed -E 's/^## ([0-9]{4}-[0-9]{2}-[0-9]{2}).*/\1/')
  if [[ -n "${newest}" ]]; then
    newest_ts=$(date -j -f "%Y-%m-%d" "${newest}" +%s 2>/dev/null || date -d "${newest}" +%s 2>/dev/null || echo 0)
    if [[ "${newest_ts}" -gt 0 ]]; then
      now_ts=$(date +%s)
      age_days=$(( (now_ts - newest_ts) / 86400 ))
      if [[ "${age_days}" -gt 7 ]]; then
        add_finding "[STALE] docs/PROGRESS_LOG.md newest entry is ${newest} (${age_days} days ago). Loop may be stalled."
      fi
    fi
  else
    add_finding "[WARN] docs/PROGRESS_LOG.md has no dated entries (looking for '## YYYY-MM-DD'). Add a slice receipt."
  fi
fi

# Bug fix: previous AWK had two `^### <prefix>` rules with `next` on the first,
# making the second unreachable. Only the LAST malformed entry was reported.
# Now uses a flush() function called at the start of each new entry so all
# malformed entries are captured.
check_marker_field() {
  local file="$1"
  local marker_re="$2"   # e.g. "^### Q-"
  local field_re="$3"    # e.g. "^-? *Recommended default:"
  local heading="$4"     # the parent finding line
  [[ -f "${file}" ]] || return 0

  local bad
  bad=$(awk -v marker="${marker_re}" -v field="${field_re}" '
    function flush() {
      if (current != "" && !has_field) print current
      current = ""
      has_field = 0
    }
    $0 ~ marker { flush(); current = $0; next }
    $0 ~ field { has_field = 1; next }
    END { flush() }
  ' "${file}")

  [[ -z "${bad}" ]] && return 0
  add_finding "${heading}"
  while IFS= read -r line; do
    [[ -n "${line}" ]] && add_finding "    ${line}"
  done <<< "${bad}"
}

# Check 6: open questions without recommended defaults
check_marker_field \
  "docs/OPEN_QUESTIONS.md" \
  "^### Q-" \
  "^-? *Recommended default:" \
  "[WARN] docs/OPEN_QUESTIONS.md has Q-NNN entries without 'Recommended default:'. The loop will block on these. Add defaults so the loop ships under them."

# Check 7: followups without priority
check_marker_field \
  "docs/FOLLOWUPS.md" \
  "^### F-" \
  "^-? *Priority:" \
  "[WARN] docs/FOLLOWUPS.md has F-NNN entries without 'Priority:'. Tag each with blocks-release | nice-to-have | polish."

# Check 8: em-dash drift in canonical files (U+2014 em-dash, U+2013 en-dash).
emdash_hits=$(grep -lP '[\x{2014}\x{2013}]' \
  AGENTS.md \
  CLAUDE.md \
  docs/IMPLEMENTATION_PLAN.md \
  docs/WORKING_AGREEMENT.md \
  docs/PROGRESS_LOG.md \
  docs/OPEN_QUESTIONS.md \
  docs/FOLLOWUPS.md \
  docs/PLAYTEST.md \
  docs/FUN_FACTOR_AUDIT.md \
  docs/GDD_COVERAGE.json \
  docs/gdd/README.md \
  .claude/rules/slice-discipline.md \
  .claude/rules/ledger-append-only.md \
  .claude/rules/gdd-build-log.md \
  2>/dev/null || true)
if [[ -n "${emdash_hits}" ]]; then
  add_finding "[STYLE] Em-dash or en-dash found in canonical files. Replace with periods, commas, colons, or parens:"
  while IFS= read -r line; do
    [[ -n "${line}" ]] && add_finding "    ${line}"
  done <<< "${emdash_hits}"
fi

# Output
echo "spiral audit on ${TARGET_DIR}"
echo

if [[ "${#findings[@]}" -eq 0 ]]; then
  echo "Clean. No findings."
  exit 0
fi

echo "Findings:"
echo
for f in "${findings[@]}"; do
  echo "- ${f}"
done

echo
echo "Re-run after remediation."
exit 1
