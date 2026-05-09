#!/usr/bin/env bash
#
# vibekit add: pin @randroids-dojo/vibekit in the current repo's package.json
# at a github tag, run the project's lockfile-refresh, and print the matching
# DEPENDENCY_LEDGER.md entry to paste into the project's spiral ledger.
#
# Usage:
#   bash add.sh [tag]
#
# Defaults:
#   tag = latest published release tag from Randroids-Dojo/VibeKit
#
# Flags:
#   --no-install   Skip the lockfile-refresh step.

set -uo pipefail

TARGET_DIR="$(pwd)"
TAG=""
INSTALL=1

for arg in "$@"; do
  case "${arg}" in
    --no-install) INSTALL=0 ;;
    --*) echo "Unknown flag: ${arg}" >&2; exit 2 ;;
    *) if [[ -z "${TAG}" ]]; then TAG="${arg}"; else echo "Unexpected positional arg: ${arg}" >&2; exit 2; fi ;;
  esac
done

if [[ ! -f "${TARGET_DIR}/package.json" ]]; then
  echo "vibekit add: no package.json found in ${TARGET_DIR}." >&2
  echo "             Run this from a project root that has a package.json." >&2
  exit 1
fi

# Resolve target tag.
if [[ -z "${TAG}" ]]; then
  if ! command -v gh >/dev/null 2>&1; then
    echo "vibekit add: gh CLI not on PATH and no tag passed; cannot resolve latest." >&2
    echo "             Pass an explicit tag, e.g.: vibekit add v0.1.0" >&2
    exit 1
  fi
  TAG=$(gh api repos/Randroids-Dojo/VibeKit/releases/latest --jq .tag_name 2>/dev/null || true)
  if [[ -z "${TAG}" ]]; then
    echo "vibekit add: could not resolve latest tag via gh." >&2
    echo "             The repo may have no published releases yet; pass --tag v0.1.0 explicitly." >&2
    exit 1
  fi
fi

# Validate tag shape.
case "${TAG}" in
  v[0-9]*) : ;;
  *) echo "vibekit add: tag '${TAG}' does not start with 'v<digit>'. Refusing." >&2; exit 1 ;;
esac

PIN_VALUE="github:Randroids-Dojo/VibeKit#${TAG}"
PKG="${TARGET_DIR}/package.json"

# Detect current pin (if any) using node so we do not parse JSON with sed.
CURRENT=$(node -e '
  const p = require(process.argv[1]);
  const v = (p.dependencies && p.dependencies["@randroids-dojo/vibekit"])
    || (p.devDependencies && p.devDependencies["@randroids-dojo/vibekit"])
    || "";
  process.stdout.write(v);
' "${PKG}" 2>/dev/null || true)

if [[ "${CURRENT}" == "${PIN_VALUE}" ]]; then
  echo "vibekit add: @randroids-dojo/vibekit already pinned at ${TAG}. Nothing to do."
  exit 0
fi

# Patch package.json via node (preserves formatting via JSON.stringify with 2-space indent).
node -e '
  const fs = require("fs");
  const path = process.argv[1];
  const pin = process.argv[2];
  const pkg = JSON.parse(fs.readFileSync(path, "utf8"));
  pkg.dependencies = pkg.dependencies || {};
  pkg.dependencies["@randroids-dojo/vibekit"] = pin;
  fs.writeFileSync(path, JSON.stringify(pkg, null, 2) + "\n");
' "${PKG}" "${PIN_VALUE}"

echo "vibekit add: pinned @randroids-dojo/vibekit -> ${PIN_VALUE} in package.json"

# Lockfile refresh.
if [[ "${INSTALL}" -eq 1 ]]; then
  if [[ -f "${TARGET_DIR}/pnpm-lock.yaml" ]] && command -v pnpm >/dev/null 2>&1; then
    echo "vibekit add: running pnpm install"
    (cd "${TARGET_DIR}" && pnpm install)
  elif [[ -f "${TARGET_DIR}/yarn.lock" ]] && command -v yarn >/dev/null 2>&1; then
    echo "vibekit add: running yarn install"
    (cd "${TARGET_DIR}" && yarn install)
  elif [[ -f "${TARGET_DIR}/package-lock.json" ]] && command -v npm >/dev/null 2>&1; then
    echo "vibekit add: running npm install"
    (cd "${TARGET_DIR}" && npm install)
  else
    echo "vibekit add: no lockfile found; skipping install. Run your package manager manually."
  fi
fi

# Print the DEPENDENCY_LEDGER entry to paste.
cat <<EOF

----- DEPENDENCY_LEDGER.md entry -----
Paste this under the 'Watch list' section of your project's
docs/DEPENDENCY_LEDGER.md (or Docs/ if the project uses that case).
If an entry already exists, update its 'Currently pinned' line.

### \`@randroids-dojo/vibekit\`

- **Why watched**: internally maintained, pre-1.0, breaking changes possible on every release.
- **Source**: https://github.com/Randroids-Dojo/VibeKit/releases
- **Pin format**: \`github:Randroids-Dojo/VibeKit#vX.Y.Z\` (tag-pinned).
- **Currently pinned**: \`${TAG}\`
- **Detect-new**: \`gh api repos/Randroids-Dojo/VibeKit/releases/latest --jq .tag_name\`
- **Migration notes**: pre-1.0 means any release may break callers. Read the kit's CHANGELOG.md between pinned and target tag. Type errors usually surface in type-check; smoke any feature that imports from the kit.

----- next steps -----
- Run your project's type-check.
- Run unit + smoke tests for any feature that imports from the kit.
- Server-only modules live under @randroids-dojo/vibekit/server (kv, sign, rate-limit). Do NOT import them from client code.
- For per-module wire-up patterns: /vibekit cookbook
EOF
