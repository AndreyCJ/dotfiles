#!/usr/bin/env bash
#
# Regenerate the committed Brewfile from the currently installed
# Homebrew packages.
#
# Usage:
#   bin/backup-brewfile.sh           # dump only; review Brewfile, then...
#   bin/backup-brewfile.sh --commit  # commit + push the reviewed Brewfile
#
# Only the Brewfile is ever staged — unrelated working-tree changes are
# left untouched.

set -e

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
BREWFILE="$DOTFILES/Brewfile"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "ERROR: Brewfile backup is macOS-only." >&2
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "ERROR: brew not found; cannot dump Brewfile." >&2
  exit 1
fi

dump_brewfile() {
  # --no-vscode: brew dump shells out to `code --list-extensions`, which
  # can hang on macOS. Extensions are tracked by the vscode package instead.
  brew bundle dump --force --no-vscode --file="$BREWFILE"
}

commit_and_push() {
  cd "$DOTFILES"
  if git diff --quiet -- Brewfile; then
    echo "Brewfile unchanged — nothing to commit."
    exit 0
  fi
  git add Brewfile
  git commit -m "chore(brew): update Brewfile from installed packages"
  git push
}

if [[ "${1:-}" == "--commit" ]]; then
  dump_brewfile
  commit_and_push
else
  dump_brewfile
  if git -C "$DOTFILES" diff --quiet -- Brewfile; then
    echo "Brewfile up to date."
    exit 0
  fi
  echo "Brewfile updated:"
  git -C "$DOTFILES" diff --stat -- Brewfile
  git -C "$DOTFILES" diff -- Brewfile
  echo "Review the Brewfile, then run: bin/backup-brewfile.sh --commit"
fi