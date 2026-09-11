#!/usr/bin/env bash

set -e

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
OS="$(uname -s)"

COMMON_STOW_PKGS=(git nvim starship tmux vim wakatime zsh ghostty ssh yazi herdr opencode)
MACOS_STOW_PKGS=(aerospace vscode-macos)
LINUX_STOW_PKGS=(vscode-linux hypr omarchy)

# Note: MacOS system packages are located in Brewfile
LINUX_SYSTEM_PKGS=(stow eza fzf zoxide starship mise tmux ghostty bitwarden)

OMARCHY_PLUGINS=(
  "https://github.com/JoshZ7/omarchy-afterglow.git"
  "https://github.com/mrpbennett/omarchy-sesh.git"
  "https://github.com/c4software/hyprland-alttab.git"
  "https://github.com/techywilbur/omarchy-pomodoro.git"
)

install_macos() {
  echo "Applying macOS settings..."
  "$DOTFILES/macos/defaults.sh" || true

  echo "Installing Homebrew..."
  if ! command -v brew >/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  echo "Installing packages (Brewfile)..."
  brew bundle --file="$DOTFILES/Brewfile"

  install_oh_my_zsh

  echo "Creating config directories..."
  mkdir -p "$HOME/.config"
  mkdir -p "$HOME/.ssh"
  mkdir -p "$HOME/Library/Application Support/Code/User"

  stow_dotfiles "${MACOS_STOW_PKGS[@]}"
  link_ghostty_platform
}

install_linux() {
  echo "Installing system packages..."

  if ! command -v stow >/dev/null 2>&1; then
    echo "Installing stow..."
    sudo pacman -S --needed --noconfirm stow
  fi

  if ! command -v zsh >/dev/null 2>&1; then
    echo "Installing zsh..."
    sudo pacman -S --needed --noconfirm zsh
  fi

  # Install common tools via pacman (fallback if omarchy pkg not available)
  echo "Installing common tools (${LINUX_SYSTEM_PKGS[*]}, git)..."
  if command -v omarchy >/dev/null 2>&1; then
    # Prefer omarchy pkg wrapper
    omarchy pkg add --needed "${LINUX_SYSTEM_PKGS[@]}" 2>/dev/null || \
      sudo pacman -S --needed --noconfirm "${LINUX_SYSTEM_PKGS[@]}" git 2>/dev/null || true
  else
    sudo pacman -S --needed --noconfirm "${LINUX_SYSTEM_PKGS[@]}" git 2>/dev/null || true
  fi

  install_oh_my_zsh

  sudo pacman -S --needed --noconfirm zsh-autosuggestions zsh-syntax-highlighting 2>/dev/null || true

  echo "Creating config directories..."
  mkdir -p "$HOME/.config"
  mkdir -p "$HOME/.ssh"
  mkdir -p "$HOME/.config/Code/User"

  remove_conflicting_configs
  stow_dotfiles "${LINUX_STOW_PKGS[@]}"
  install_omarchy_plugins
  link_ghostty_platform
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

remove_conflicting_configs() {
  # Fresh Omarchy has regular files where dotfiles wants symlinks — remove so stow can link
  echo "Removing existing configs that conflict with repo (fresh Omarchy)..."
  for f in \
    "$HOME/.config/nvim" \
    "$HOME/.config/ghostty/config" \
    "$HOME/.config/starship.toml" \
    "$HOME/.config/tmux/tmux.conf" \
    "$HOME/.config/Code/User/settings.json" \
    "$HOME/.config/Code/User/keybindings.json" \
    "$HOME/.zshrc" \
    "$HOME/.ssh/config" \
    "$HOME/.config/hypr" \
    "$HOME/.config/omarchy" \
    "$HOME/.config/yazi" \
    "$HOME/.config/herdr" \
    "$HOME/.gitconfig" \
    "$HOME/.vimrc"
  do
    if [[ -e "$f" && ! -L "$f" ]]; then
      echo "  Removing $f"
      rm -rf "$f"
    fi
  done
}

stow_dotfiles() {
  # $@: OS-specific stow package list. Explicit list avoids stow . fragility and handles split vscode
  echo "Applying symlinks with Stow..."
  cd "$DOTFILES"
  stow -v "${COMMON_STOW_PKGS[@]}" "$@"
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

link_ghostty_platform() {
  # Ghostty: shared config references a per-platform file via a `?` include
  # (silently skipped when missing). Stow never links these (see .stow-local-ignore),
  # so link the right one per OS here.
  if [[ "$OS" == "Darwin" ]]; then
    ln -snf "$DOTFILES/ghostty/.config/ghostty/macos.conf" \
      "$HOME/.config/ghostty/macos.conf"
  else
    ln -snf "$DOTFILES/ghostty/.config/ghostty/linux.conf" \
      "$HOME/.config/ghostty/linux.conf"
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
  # Handle wakatime env (if .env with WAKAPI_KEY exists)
  if [[ -f "$DOTFILES/.env" ]]; then
    source "$DOTFILES/.env"
    if [[ -n "${WAKAPI_KEY:-}" ]]; then
      echo "Generating wakatime config from template..."
      if command -v envsubst >/dev/null 2>&1; then
        envsubst < "$DOTFILES/wakatime/.wakatime.cfg.template" > "$HOME/.wakatime.cfg"
      else
        # Fallback without envsubst
        sed "s|\${WAKAPI_KEY}|$WAKAPI_KEY|g" "$DOTFILES/wakatime/.wakatime.cfg.template" > "$HOME/.wakatime.cfg"
      fi
    fi
  elif [[ -f "$DOTFILES/wakatime/.wakatime.cfg.template" ]] && command -v envsubst >/dev/null 2>&1 && [[ -f "$HOME/.env" ]]; then
    envsubst < "$DOTFILES/wakatime/.wakatime.cfg.template" > "$HOME/.wakatime.cfg" 2>/dev/null || true
  fi
}

main() {
  echo "Dotfiles: $DOTFILES"
  echo "OS: $OS"

  if [[ "$OS" == "Darwin" ]]; then
    install_macos
  else
    install_linux
  fi

  setup_wakatime

  echo "Done. Packages installed: ${COMMON_STOW_PKGS[*]} + OS-specific."
  if [[ "$OS" != "Darwin" ]]; then
    echo "Hyprland: run 'hyprctl reload' to apply. Shell: 'omarchy restart shell' if needed."
  fi
}

main "$@"
