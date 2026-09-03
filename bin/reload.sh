#!/usr/bin/env bash
#
# Reload Hyprland + Omarchy configs after editing dotfiles.
# Repo is source of truth (~/.config entries are stow symlinks),
# so this only reloads — it never copies files.
#
# Usage: ~/dotfiles/bin/reload.sh

set -e

echo "==> hyprctl reload"
hyprctl reload

echo "==> hyprctl configerrors"
if ! hyprctl configerrors; then
  echo "ERROR: hypr config has errors (see above)" >&2
  exit 1
fi

if command -v omarchy >/dev/null 2>&1; then
  echo "==> omarchy restart shell"
  omarchy restart shell

  echo "==> omarchy restart terminal"
  omarchy restart terminal
else
  echo "Skipping omarchy restarts: omarchy CLI not found (macOS?)" >&2
fi

echo "Done. Note: Ghostty font-family changes need a full Ghostty restart, not just reload."
