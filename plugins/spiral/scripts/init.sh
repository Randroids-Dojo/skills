#!/usr/bin/env bash
#
# spiral init: bootstrap the structural-discipline scaffold into the current repo.
#
# Usage:
#   bash init.sh "<project-name>" "<one-line-pitch>" "<stack>"
#
# Refuses to run if AGENTS.md already exists. Use audit.sh on existing repos.

set -euo pipefail

PROJECT_NAME="${1:-}"
PITCH="${2:-}"
STACK="${3:-}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="${SCRIPT_DIR}/../templates"
TARGET_DIR="$(pwd)"
TODAY="$(date +%Y-%m-%d)"

if [[ -z "${PROJECT_NAME}" ]]; then
  read -r -p "Project name: " PROJECT_NAME
fi
if [[ -z "${PITCH}" ]]; then
  read -r -p "One-line pitch: " PITCH
fi
if [[ -z "${STACK}" ]]; then
  read -r -p "Stack (e.g. 'Next.js + Three.js + Vercel KV'): " STACK
fi

if [[ -z "${PROJECT_NAME}" || -z "${PITCH}" || -z "${STACK}" ]]; then
  echo "Error: project name, pitch, and stack are all required." >&2
  exit 1
fi

if [[ -e "${TARGET_DIR}/AGENTS.md" ]]; then
  echo "Error: AGENTS.md already exists at ${TARGET_DIR}." >&2
  echo "       Use audit.sh on existing repos." >&2
  exit 1
fi

mkdir -p "${TARGET_DIR}/docs/gdd" "${TARGET_DIR}/.claude/rules"

# Bash parameter expansion does literal string replacement (no regex), so user
# input containing &, |, \, etc. is safe. Earlier `sed` form was vulnerable.
substitute() {
  local src="$1"
  local dst="$2"
  local content
  content=$(<"${src}")
  content="${content//\{\{PROJECT_NAME\}\}/${PROJECT_NAME}}"
  content="${content//\{\{PITCH\}\}/${PITCH}}"
  content="${content//\{\{STACK\}\}/${STACK}}"
  content="${content//\{\{TODAY\}\}/${TODAY}}"
  printf '%s' "${content}" > "${dst}"
}

# template-name : destination-path-relative-to-target-dir
manifest=(
  "AGENTS.md:AGENTS.md"
  "CLAUDE.md:CLAUDE.md"
  "IMPLEMENTATION_PLAN.md:docs/IMPLEMENTATION_PLAN.md"
  "WORKING_AGREEMENT.md:docs/WORKING_AGREEMENT.md"
  "docs-gdd-README.md:docs/gdd/README.md"
  "GDD_COVERAGE.json:docs/GDD_COVERAGE.json"
  "PROGRESS_LOG.md:docs/PROGRESS_LOG.md"
  "OPEN_QUESTIONS.md:docs/OPEN_QUESTIONS.md"
  "FOLLOWUPS.md:docs/FOLLOWUPS.md"
  "DEPENDENCY_LEDGER.md:docs/DEPENDENCY_LEDGER.md"
  "PLAYTEST.md:docs/PLAYTEST.md"
  "FUN_FACTOR_AUDIT.md:docs/FUN_FACTOR_AUDIT.md"
  # Path-scoped Rules (.claude/rules/*.md). Read by Claude Code based on
  # the YAML frontmatter `paths:` field. Codex picks them up via the symlinks
  # created below.
  "dot-claude-rules-slice-discipline.md:.claude/rules/slice-discipline.md"
  "dot-claude-rules-ledger-append-only.md:.claude/rules/ledger-append-only.md"
  "dot-claude-rules-gdd-build-log.md:.claude/rules/gdd-build-log.md"
)

written=()
for entry in "${manifest[@]}"; do
  src_name="${entry%%:*}"
  dst_path="${entry#*:}"
  substitute "${TEMPLATES_DIR}/${src_name}" "${TARGET_DIR}/${dst_path}"
  written+=("${dst_path}")
done

# Codex symlinks: each .claude/rules/X.md gets a per-directory AGENTS.md
# alias so Codex picks it up via its root-down AGENTS.md walk.
# - docs/AGENTS.md    -> ledger-append-only (covers ledger files in docs/)
# - docs/gdd/AGENTS.md -> gdd-build-log     (covers GDD section files)
# slice-discipline covers source dirs that do not exist yet at init time.
# Users add `<src-dir>/AGENTS.md` symlinks themselves; the AGENTS.md template
# documents the pattern under the "Cross-tool Rules" section.
ln -sf "../.claude/rules/ledger-append-only.md" "${TARGET_DIR}/docs/AGENTS.md"
written+=("docs/AGENTS.md (symlink to .claude/rules/ledger-append-only.md)")

ln -sf "../../.claude/rules/gdd-build-log.md" "${TARGET_DIR}/docs/gdd/AGENTS.md"
written+=("docs/gdd/AGENTS.md (symlink to .claude/rules/gdd-build-log.md)")

# Em-dash sanity check on the written files (U+2014 em-dash, U+2013 en-dash).
if grep -lP '[\x{2014}\x{2013}]' "${TARGET_DIR}/AGENTS.md" "${TARGET_DIR}/CLAUDE.md" "${TARGET_DIR}"/docs/*.md "${TARGET_DIR}"/docs/gdd/*.md "${TARGET_DIR}"/.claude/rules/*.md 2>/dev/null | grep -q .; then
  echo
  echo "WARNING: em-dash or en-dash detected in written files. This violates Rule 1." >&2
  echo "         Inspect and replace before committing." >&2
fi

echo "spiral init complete. Wrote:"
for f in "${written[@]}"; do
  echo "  ${f}"
done

cat <<EOF

Next steps:
  1. Draft the first GDD section under docs/gdd/01-vision-and-pillars.md.
  2. Replace the example rows in docs/GDD_COVERAGE.json with real atomic requirements.
  3. Start the loop: /randroid-loop implement
EOF
