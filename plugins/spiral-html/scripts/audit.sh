#!/usr/bin/env bash
#
# spiral-html audit: diff a target repo against the canonical HTML-first
# spiral scaffold.
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

cd "${TARGET_DIR}" || {
  echo "Error: cannot enter ${TARGET_DIR}." >&2
  exit 1
}

findings=()
add_finding() {
  findings+=("$1")
}

# Check 1: missing canonical files
canonical=(
  "AGENTS.md"
  "CLAUDE.md"
  "docs/IMPLEMENTATION_PLAN.html"
  "docs/WORKING_AGREEMENT.html"
  "docs/gdd/index.html"
  "docs/GDD_COVERAGE.json"
  "docs/PROGRESS_LOG.html"
  "docs/OPEN_QUESTIONS.html"
  "docs/FOLLOWUPS.html"
  "docs/DEPENDENCY_LEDGER.html"
  "docs/PLAYTEST.html"
  "docs/FUN_FACTOR_AUDIT.html"
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
    add_finding "[MISSING] ${f} does not exist. Run /spiral-html init or copy the template manually."
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

# AGENTS.md should be the full contract (RULE 1..N, em-dash ban, etc.).
# CLAUDE.md should import it via `@AGENTS.md` so Claude Code picks up the same rules.
if [[ -f "AGENTS.md" ]] && ! grep -q "RULE 1" "AGENTS.md" 2>/dev/null; then
  add_finding "[CONTRACT] AGENTS.md exists but does not contain the contract rules (looking for 'RULE 1'). The HTML-first scaffold keeps AGENTS.md and CLAUDE.md as Markdown so Codex's root-down walk and Claude Code's project-memory import keep working. Re-copy the template."
fi
if [[ -f "CLAUDE.md" ]] && ! grep -q "@AGENTS.md" "CLAUDE.md" 2>/dev/null; then
  add_finding "[CONTRACT] CLAUDE.md exists but does not import AGENTS.md (looking for '@AGENTS.md'). It should be a one-line file: '@AGENTS.md'."
fi

# Check 2: monolith GDD
if [[ -f "docs/GDD.html" && ! -d "docs/gdd" ]]; then
  add_finding "[ANTI-PATTERN] docs/GDD.html exists as a single file. Split into docs/gdd/<n>-<title>.html per requirement. A monolith GDD makes coverage rows chapter-granular by default, which is the Flatline failure mode."
fi

# Check 3: chapter-granular coverage
if [[ -f "docs/GDD_COVERAGE.json" ]]; then
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
    age_days=$(git log --reverse --pretty=format:%ct 2>/dev/null | head -1 | awk -v now="$(date +%s)" '{ if ($0 != "") print int((now - $0) / 86400) }')
    if [[ -n "${age_days}" && "${age_days}" -gt 0 ]]; then
      project_weeks=$(( (age_days + 6) / 7 ))
      [[ "${project_weeks}" -lt 1 ]] && project_weeks=1
      threshold=$(( project_weeks * 14 ))
      if [[ "${rows}" -lt "${threshold}" ]]; then
        add_finding "[ANTI-PATTERN] docs/GDD_COVERAGE.json has ${rows} rows for a ~${age_days}-day-old project (~${project_weeks} weeks). Heuristic threshold is ${threshold} (14 rows / project-week). This is likely chapter-granular coverage. The Flatline failure mode is rows that flip to 'done' once any code lands. Split into requirement-granular rows."
      fi
    fi
  fi
fi

# Check 4: missing qualitative gate
if [[ ! -f "docs/PLAYTEST.html" ]]; then
  add_finding "[ANTI-FLATLINE] docs/PLAYTEST.html is missing. Without the second qualitative gate, the loop terminates when systems exist instead of when the product is good."
fi
if [[ ! -f "docs/FUN_FACTOR_AUDIT.html" ]]; then
  add_finding "[ANTI-FLATLINE] docs/FUN_FACTOR_AUDIT.html is missing. Without a periodic gap audit, the backlog will not surface the experience-level work that coverage rows cannot catch."
fi

# Check 5: stale progress log. Newest article carries data-date="YYYY-MM-DD".
if [[ -f "docs/PROGRESS_LOG.html" ]]; then
  newest=$(grep -oE 'data-date="[0-9]{4}-[0-9]{2}-[0-9]{2}"' docs/PROGRESS_LOG.html \
    | sed -E 's/data-date="([0-9-]+)"/\1/' \
    | sort -r | head -1)
  if [[ -n "${newest}" ]]; then
    newest_ts=$(date -j -f "%Y-%m-%d" "${newest}" +%s 2>/dev/null || date -d "${newest}" +%s 2>/dev/null || echo 0)
    if [[ "${newest_ts}" -gt 0 ]]; then
      now_ts=$(date +%s)
      age_days=$(( (now_ts - newest_ts) / 86400 ))
      if [[ "${age_days}" -gt 7 ]]; then
        add_finding "[STALE] docs/PROGRESS_LOG.html newest entry is ${newest} (${age_days} days ago). Loop may be stalled."
      fi
    fi
  else
    add_finding "[WARN] docs/PROGRESS_LOG.html has no dated entries (looking for <article data-date=\"YYYY-MM-DD\">). Add a slice receipt."
  fi
fi

# Check 6: open questions without recommended default.
# Each open question is a <section data-q="..."> containing a <dt>Recommended default</dt> entry.
if [[ -f "docs/OPEN_QUESTIONS.html" ]]; then
  # Skip the template example (which lives inside a <pre><code> block).
  # Extract one logical question block per data-q occurrence and inspect each.
  bad_qs=$(python3 - <<'PY'
import re, sys
try:
    src = open('docs/OPEN_QUESTIONS.html', encoding='utf-8').read()
except Exception:
    sys.exit(0)

# Strip <pre>...</pre> blocks so the template example does not register.
src_stripped = re.sub(r'<pre.*?</pre>', '', src, flags=re.DOTALL | re.IGNORECASE)

# Find every <section data-q="...">...</section> in the stripped source.
pattern = re.compile(r'<section[^>]*data-q="([^"]+)"[^>]*>(.*?)</section>', re.DOTALL | re.IGNORECASE)
missing = []
for m in pattern.finditer(src_stripped):
    qid = m.group(1)
    body = m.group(2)
    if not re.search(r'<dt>\s*Recommended default\s*</dt>', body, re.IGNORECASE):
        missing.append(qid)

for qid in missing:
    print(qid)
PY
)
  if [[ -n "${bad_qs}" ]]; then
    add_finding "[WARN] docs/OPEN_QUESTIONS.html has entries without a <dt>Recommended default</dt>. The loop will block on these. Add defaults so the loop ships under them:"
    while IFS= read -r line; do
      [[ -n "${line}" ]] && add_finding "    Q-id: ${line}"
    done <<< "${bad_qs}"
  fi
fi

# Check 7: followups without data-priority attribute.
if [[ -f "docs/FOLLOWUPS.html" ]]; then
  bad_fs=$(python3 - <<'PY'
import re, sys
try:
    src = open('docs/FOLLOWUPS.html', encoding='utf-8').read()
except Exception:
    sys.exit(0)

src_stripped = re.sub(r'<pre.*?</pre>', '', src, flags=re.DOTALL | re.IGNORECASE)
pattern = re.compile(r'<section[^>]*data-f="([^"]+)"[^>]*>', re.IGNORECASE)
missing = []
for m in pattern.finditer(src_stripped):
    tag = m.group(0)
    fid = m.group(1)
    if 'data-priority=' not in tag.lower():
        missing.append(fid)

for fid in missing:
    print(fid)
PY
)
  if [[ -n "${bad_fs}" ]]; then
    add_finding "[WARN] docs/FOLLOWUPS.html has entries without a data-priority attribute. Tag each with data-priority=\"blocks-release\" | \"nice-to-have\" | \"polish\":"
    while IFS= read -r line; do
      [[ -n "${line}" ]] && add_finding "    F-id: ${line}"
    done <<< "${bad_fs}"
  fi
fi

# Check 8: em-dash drift in canonical files (U+2014 em-dash, U+2013 en-dash).
emdash_hits=$(grep -lE '—|–' \
  AGENTS.md \
  CLAUDE.md \
  docs/IMPLEMENTATION_PLAN.html \
  docs/WORKING_AGREEMENT.html \
  docs/PROGRESS_LOG.html \
  docs/OPEN_QUESTIONS.html \
  docs/FOLLOWUPS.html \
  docs/DEPENDENCY_LEDGER.html \
  docs/PLAYTEST.html \
  docs/FUN_FACTOR_AUDIT.html \
  docs/GDD_COVERAGE.json \
  docs/gdd/index.html \
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

# Check 9: dependency ledger present and has a watch-list region.
if [[ -f "docs/DEPENDENCY_LEDGER.html" ]]; then
  if ! grep -qE '<section[^>]+id="watch-list"' docs/DEPENDENCY_LEDGER.html 2>/dev/null; then
    add_finding "[DEPS] docs/DEPENDENCY_LEDGER.html exists but has no <section id=\"watch-list\"> region. The Dependency Upgrade Gate cannot find watched deps. Re-copy the template or add the section."
  fi
fi

# Output
echo "spiral-html audit on ${TARGET_DIR}"
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
