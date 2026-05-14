#!/usr/bin/env bash
set -euo pipefail

repo="Randroids-Dojo/dots-html"
install_dir="${DOT_INSTALL_DIR:-$HOME/.local/bin}"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$install_dir"

os="$(uname -s | tr '[:upper:]' '[:lower:]')"
arch="$(uname -m)"
case "$os" in
  darwin) os="darwin" ;;
  linux) os="linux" ;;
  *) os="" ;;
esac
case "$arch" in
  arm64|aarch64) arch="arm64" ;;
  x86_64|amd64) arch="x86_64" ;;
  *) arch="" ;;
esac

asset=""
if [[ -n "$os" && -n "$arch" ]]; then
  asset="dot-html-${os}-${arch}"
  url="https://github.com/${repo}/releases/latest/download/${asset}"
  if curl -fsSL "$url" -o "$tmp_dir/dot-html"; then
    chmod +x "$tmp_dir/dot-html"
    mv "$tmp_dir/dot-html" "$install_dir/dot-html"
    echo "Installed $repo release asset $asset to $install_dir/dot-html"
    "$install_dir/dot-html" --version
    exit 0
  fi
fi

if ! command -v zig >/dev/null 2>&1; then
  echo "No matching release asset found and zig is not installed." >&2
  echo "Install Zig 0.15+ or set DOT_INSTALL_DIR, then rerun this script." >&2
  exit 1
fi

git clone --depth 1 "https://github.com/${repo}.git" "$tmp_dir/dots-html"
(
  cd "$tmp_dir/dots-html"
  zig build -Doptimize=ReleaseSmall
)
cp "$tmp_dir/dots-html/zig-out/bin/dot-html" "$install_dir/dot-html"
chmod +x "$install_dir/dot-html"
echo "Built and installed $repo from source to $install_dir/dot-html"
"$install_dir/dot-html" --version
