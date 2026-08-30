#!/usr/bin/env bash

set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_dir"

node scripts/validate-portability.mjs

while IFS= read -r -d '' script; do
  bash -n "$script"
done < <(find plugins -type f -name '*.sh' -print0)

pycache_dir="$(mktemp -d)"
cleanup() {
  rm -rf "$pycache_dir"
}
trap cleanup EXIT

while IFS= read -r -d '' script; do
  PYTHONPYCACHEPREFIX="$pycache_dir" python3 -m py_compile "$script"
done < <(find plugins -type f -name '*.py' -print0)

if [[ "${VALIDATE_EXTERNAL:-1}" == "1" ]]; then
  skills_ref_source="git+https://github.com/agentskills/agentskills@69ef37e9424c0a7ea9dd2293b559e43ec8176379#subdirectory=skills-ref"
  while IFS= read -r -d '' skill_file; do
    uvx --from "$skills_ref_source" skills-ref validate "$(dirname "$skill_file")"
  done < <(find plugins -type f -name SKILL.md -print0)

  npx --yes skills add . --list --full-depth >/dev/null

  if command -v claude >/dev/null 2>&1; then
    claude plugin validate .
    while IFS= read -r -d '' manifest; do
      claude plugin validate "$(dirname "$(dirname "$manifest")")"
    done < <(find plugins -path '*/.claude-plugin/plugin.json' -print0)
  fi
fi

echo "All skill checks passed."
