#!/usr/bin/env bash

set -e

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
OS="$(uname -s)"

COMMON_STOW_PKGS=(git nvim starship tmux vim wakatime zsh ghostty ssh yazi herdr opencode mise)
MACOS_STOW_PKGS=(aerospace vscode-macos)
LINUX_STOW_PKGS=(vscode-linux hypr omarchy)

# Note: MacOS system packages are located in Brewfile, Linux ones in Pacfile
PACFILE="$DOTFILES/Pacfile"

OMARCHY_PLUGINS=(
  "https://github.com/JoshZ7/omarchy-afterglow.git"
  "https://github.com/techywilbur/omarchy-pomodoro.git"
  "https://github.com/Codesmith28/omalt-tab.git"
  "https://github.com/ehlxr/advanced-workspaces.git"
  "https://github.com/SmoothPixels/cursor-accent.git"
  "https://github.com/njpatel/omapager.git"
)

install_macos() {
  echo "Applying macOS settings..."
  "$DOTFILES/macos/defaults.sh" || true

  echo "Installing Homebrew..."
  if ! command -v brew >/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  echo "Installing packages (Brewfile)..."
  if ! brew bundle --file="$DOTFILES/Brewfile"; then
    echo "WARNING: brew bundle failed, continuing..." >&2
  fi

  install_oh_my_zsh

  echo "Creating config directories..."
  mkdir -p "$HOME/.config"
  mkdir -p "$HOME/.ssh"
  mkdir -p "$HOME/Library/Application Support/Code/User"

  remove_conflicting_configs "${COMMON_CONFLICTS[@]}" "${MACOS_CONFLICTS[@]}"
  stow_dotfiles "${MACOS_STOW_PKGS[@]}"
}

# Fills LINUX_SYSTEM_PKGS and LINUX_AUR_PKGS with the package names listed in
# Pacfile. Blank lines and anything after a "#" are treated as comments, so the
# file can be organised into sections and annotated like the Brewfile is.
read_pacfile() {
  if [ ! -f "$PACFILE" ]; then
    echo "ERROR: Pacfile not found at $PACFILE" >&2
    exit 1
  fi

  # Every name the sync databases can serve, collected in one pass because a
  # per-package `pacman -Si` costs ~0.5s and the list runs past a hundred.
  # Deliberately not widened to `pacman -Qq`: a package that is merely
  # installed locally would then route differently on a fresh machine.
  local -A installable=()
  local name
  while read -r name; do
    if [ -n "$name" ]; then
      installable["$name"]=1
    fi
  done < <(pacman -Sl 2>/dev/null | awk '{print $2}')

  # Whatever is left is AUR-only. pacman aborts the entire batch on a name it
  # cannot resolve, so those have to be split out and sent to an AUR helper.
  LINUX_SYSTEM_PKGS=()
  LINUX_AUR_PKGS=()
  local line
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%%#*}"
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    if [ -n "$line" ]; then
      if [ -n "${installable[$line]:-}" ]; then
        LINUX_SYSTEM_PKGS+=("$line")
      else
        LINUX_AUR_PKGS+=("$line")
      fi
    fi
  done <"$PACFILE"
}

# No output suppression here: a package name pacman cannot resolve silently
# takes the whole batch down with it, so keep the errors visible.
install_pacman_pkgs() {
  if ! sudo pacman -S --needed --noconfirm "${LINUX_SYSTEM_PKGS[@]}"; then
    echo "WARNING: some packages failed to install, see the output above" >&2
  fi
}

install_aur_pkgs() {
  if [ ${#LINUX_AUR_PKGS[@]} -eq 0 ]; then
    return 0
  fi

  echo "Installing AUR packages (${LINUX_AUR_PKGS[*]})..."
  if ! command -v yay >/dev/null 2>&1; then
    echo "WARNING: no AUR helper found, skipping: ${LINUX_AUR_PKGS[*]}" >&2
    echo "         install them by hand, e.g. yay -S ${LINUX_AUR_PKGS[0]}" >&2
    return 0
  fi

  if ! yay -S --needed --noconfirm "${LINUX_AUR_PKGS[@]}"; then
    echo "WARNING: some AUR packages failed to install, see the output above" >&2
  fi
}

install_linux() {
  echo "Installing system packages (Pacfile)..."
  read_pacfile
  echo "Installing ${#LINUX_SYSTEM_PKGS[@]} repo packages and ${#LINUX_AUR_PKGS[@]} AUR packages..."

  if [ ${#LINUX_SYSTEM_PKGS[@]} -gt 0 ]; then
    # Install common tools via pacman (fallback if omarchy pkg not available)
    if command -v omarchy >/dev/null 2>&1; then
      # Prefer omarchy pkg wrapper
      omarchy pkg add --needed "${LINUX_SYSTEM_PKGS[@]}" 2>/dev/null ||
        install_pacman_pkgs
    else
      install_pacman_pkgs
    fi
  fi

  install_aur_pkgs

  install_oh_my_zsh

  echo "Creating config directories..."
  mkdir -p "$HOME/.config"
  mkdir -p "$HOME/.ssh"
  mkdir -p "$HOME/.config/Code/User"

  remove_conflicting_configs "${COMMON_CONFLICTS[@]}" "${LINUX_CONFLICTS[@]}"
  stow_dotfiles "${LINUX_STOW_PKGS[@]}"
  install_omarchy_plugins
  link_omarchy_theme
  set_default_shell
}

install_oh_my_zsh() {
  echo "Installing Oh My Zsh..."
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no sh -c \
      "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi
}

# Paths where a real file or directory would block stow. These are deleted: the
# dotfiles are the source of truth, so a config on this machine that conflicts
# with the repo is rewritten from the repo.
#
# A path belongs in the list matching the stow package that owns it -- COMMON for
# everything in COMMON_STOW_PKGS, LINUX/MACOS for the OS-specific ones. Filing a
# shared package under one OS leaves that platform uncleared, and stow then
# aborts on a path nothing was supposed to leave behind.
COMMON_CONFLICTS=(
  "$HOME/.gitconfig"
  "$HOME/.vimrc"
  "$HOME/.zshrc"
  "$HOME/.ssh/config"
  "$HOME/.config/starship.toml"
  "$HOME/.config/tmux/tmux.conf"
  "$HOME/.config/ghostty/config"
  "$HOME/.config/nvim"
  "$HOME/.config/yazi"
  "$HOME/.config/herdr"
  # Only the file, not the whole ~/.config/mise directory: stow owns nothing
  # else in there, and clearing the directory would take the rest of mise's
  # state with it.
  "$HOME/.config/mise/config.toml"
)

LINUX_CONFLICTS=(
  "$HOME/.config/hypr"
  "$HOME/.config/omarchy"
  "$HOME/.config/Code/User/settings.json"
  "$HOME/.config/Code/User/keybindings.json"
)

MACOS_CONFLICTS=(
  "$HOME/Library/Application Support/Code/User/settings.json"
  "$HOME/Library/Application Support/Code/User/keybindings.json"
)

# Deletes a real file or directory that would block stow, so the repo's version
# is linked in its place.
remove_conflicting_path() {
  local f="$1" parent
  parent="$(dirname -- "$f")"

  # Never delete through a symlinked parent. Stow links whole directories, so
  # from run 2 on ~/.config/ghostty is a symlink into this checkout and
  # ~/.config/ghostty/config is a tracked file inside it -- a `! -L` test on the
  # leaf cannot see that, and deleting it loses a dotfile stow cannot restore.
  if [[ -L "$parent" ]]; then
    return 0
  fi

  # A dangling symlink resolves to nothing, so dropping it loses nothing. One
  # that still resolves is left alone: it may point at another checkout on
  # purpose, and overwriting it is a call for the user, not a sweep.
  if [[ -L "$f" && ! -e "$f" ]]; then
    rm -f -- "$f" || true
    echo "  Removed dangling symlink $f"
  elif [[ -e "$f" && ! -L "$f" ]]; then
    echo "  Removing $f"
    rm -rf -- "$f"
  fi
}

# Clears the way for stow over the given paths.
remove_conflicting_configs() {
  echo "Removing existing configs that conflict with repo..."
  local f
  for f in "$@"; do
    remove_conflicting_path "$f"
  done
}

stow_dotfiles() {
  # $@: OS-specific stow package list. Explicit list avoids stow . fragility and handles split vscode
  echo "Applying symlinks with Stow..."

  # Purge Finder metadata in the stow tree so it can't block symlinking.
  find "$DOTFILES" "$HOME/.config" "$HOME/.ssh" "$HOME" -maxdepth 1 \
    -name '.DS_Store' -delete 2>/dev/null || true

  cd "$DOTFILES"
  # No --adopt: it imports an existing target *into the package*, so a stray
  # ~/.config/opencode/opencode.json would overwrite the repo's tracked dotfile.
  # Conflict lists cannot cover every stowed path, so an uncovered one has to
  # fail loudly here rather than destroy a file stow cannot restore. -R re-links
  # targets that are already links; plain stow would no-op, so it is belt and
  # braces rather than what makes run 2 converge.
  stow -R -v "${COMMON_STOW_PKGS[@]}" "$@"
}

install_omarchy_plugins() {
  # Must run after stow: omarchy plugin add clones into ~/.config/omarchy/plugins/<id>,
  # which post-stow is the repo dir. Re-runs tolerated (refuses existing id -> || true).
  if command -v omarchy >/dev/null 2>&1; then
    echo "Installing Omarchy shell plugins..."
    for url in "${OMARCHY_PLUGINS[@]}"; do
      omarchy plugin add "$url" --enable --yes || true
    done
  fi
}

link_omarchy_theme() {
  # Re-create the Omarchy theme symlink the nvim package can't stow (it points
  # into per-machine omarchy state). No-op when omarchy state is absent (macOS).
  # Six levels: HOME/dotfiles/nvim/.config/nvim/lua/plugins -> HOME.
  if [[ -f "$HOME/.local/state/omarchy/current/theme/neovim.lua" ]]; then
    mkdir -p "$HOME/.config/nvim/lua/plugins"
    ln -snf "$HOME/.local/state/omarchy/current/theme/neovim.lua" \
      "$HOME/.config/nvim/lua/plugins/theme.lua"
  fi
}

set_default_shell() {
  if [[ "$SHELL" != *"zsh"* ]] && command -v zsh >/dev/null 2>&1; then
    echo "Setting zsh as default shell (chsh)..."
    chsh -s "$(command -v zsh)" || true
  fi
}

setup_wakatime() {
  # The checkout's own .env wins; ~/.env is the fallback the old `elif` branch
  # half-supported, where it rendered from the ambient environment without ever
  # sourcing the file, so it only worked if the key happened to be exported.
  # Sourcing it makes that path actually work.
  local env_file="$DOTFILES/.env"
  [[ -f "$env_file" ]] || env_file="$HOME/.env"
  [[ -f "$env_file" ]] || return 0
  # shellcheck disable=SC1091
  source "$env_file"
  [[ -n "${WAKAPI_KEY:-}" ]] || return 0

  # ~/.wakatime.cfg is generated, not stowed, so this is its only writer and the
  # render always wins -- a hand edit is overwritten like any other config.
  local rendered
  rendered="$(mktemp)" || return 0
  if command -v envsubst >/dev/null 2>&1; then
    # The prefix is load-bearing: envsubst substitutes from the *environment*,
    # and the `source` above set a shell variable, not an exported one. Without
    # it an unexported WAKAPI_KEY renders `api_key = ` and breaks a working
    # config. Prefixing just this command keeps the key out of the installer's
    # other subprocesses.
    WAKAPI_KEY="$WAKAPI_KEY" envsubst \
      <"$DOTFILES/wakatime/.wakatime.cfg.template" >"$rendered"
  else
    # Expands in the shell, so it never had the problem above.
    sed "s|\${WAKAPI_KEY}|$WAKAPI_KEY|g" \
      "$DOTFILES/wakatime/.wakatime.cfg.template" >"$rendered"
  fi

  # Compare before writing: an unconditional write bumps the mtime, and a second
  # run that differs from the first in the one way a user can see is not
  # idempotent. A failed cp aborts under `set -e` and skips the rm below, so the
  # render survives as the only correct copy.
  if ! cmp -s "$rendered" "$HOME/.wakatime.cfg"; then
    cp -- "$rendered" "$HOME/.wakatime.cfg"
  fi
  rm -f "$rendered"
}

main() {
  echo "Dotfiles: $DOTFILES"
  echo "OS: $OS"

  if [[ "$OS" == "Darwin" ]]; then
    install_macos
  else
    install_linux
  fi

  # Generate ghostty's OS-specific config.ghostty (shared + platform conf)
  echo "Merging Ghostty OS-specific config..."
  "$DOTFILES/bin/merge-ghostty-config.sh"

  setup_wakatime

  echo "Done. Packages installed: ${COMMON_STOW_PKGS[*]} + OS-specific."
  if [[ "$OS" != "Darwin" ]]; then
    echo "Hyprland: run 'hyprctl reload' to apply. Shell: 'omarchy restart shell' if needed."
  fi
}

main "$@"
