#!/usr/bin/env bash

set -e

# Resolve dotfiles dir (handles ~/dotfiles vs ~/Dotfiles case on Linux)
DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"

OS="$(uname -s)"

# Common packages (cross-platform)
COMMON_PKGS="git nvim starship tmux vim wakatime zsh ghostty ssh"
MACOS_PKGS="aerospace vscode-macos"
LINUX_PKGS="vscode-linux hypr omarchy"

echo "Dotfiles: $DOTFILES"
echo "OS: $OS"

if [[ "$OS" == "Darwin" ]]; then
  echo "Applying macOS settings..."
  "$DOTFILES/macos/defaults.sh" || true

  echo "Installing Homebrew..."
  if ! command -v brew >/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  echo "Installing packages (Brewfile)..."
  brew bundle --file="$DOTFILES/Brewfile"

  echo "Installing Oh My Zsh..."
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no sh -c \
      "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  echo "Creating config directories..."
  mkdir -p "$HOME/.config"
  mkdir -p "$HOME/.ssh"
  mkdir -p "$HOME/Library/Application Support/Code/User"

  echo "Applying symlinks with Stow (macOS)..."
  cd "$DOTFILES"
  # Explicit list avoids stow . fragility and handles split vscode
  # shellcheck disable=SC2086
  stow -v $COMMON_PKGS $MACOS_PKGS

else
  echo "Detected Linux (Arch/Omarchy)..."
  echo "Installing system packages..."

  # Ensure stow + zsh are present
  if ! command -v stow >/dev/null 2>&1; then
    echo "Installing stow..."
    sudo pacman -S --needed --noconfirm stow
  fi

  if ! command -v zsh >/dev/null 2>&1; then
    echo "Installing zsh..."
    sudo pacman -S --needed --noconfirm zsh
  fi

  # Install common tools via pacman (fallback if omarchy pkg not available)
  echo "Installing common tools (eza, fzf, zoxide, starship, mise, tmux, ghostty, git)..."
  if command -v omarchy >/dev/null 2>&1; then
    # Prefer omarchy pkg wrapper
    omarchy pkg add --needed eza fzf zoxide starship mise tmux ghostty 2>/dev/null || \
      sudo pacman -S --needed --noconfirm eza fzf zoxide starship mise tmux ghostty 2>/dev/null || true
  else
    sudo pacman -S --needed --noconfirm eza fzf zoxide starship mise tmux ghostty git 2>/dev/null || true
  fi

  echo "Installing Oh My Zsh..."
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no sh -c \
      "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  # Install zsh plugins for Linux (if not using brew)
  if ! command -v brew >/dev/null 2>&1; then
    sudo pacman -S --needed --noconfirm zsh-autosuggestions zsh-syntax-highlighting 2>/dev/null || true
  fi

  echo "Creating config directories..."
  mkdir -p "$HOME/.config"
  mkdir -p "$HOME/.ssh"
  mkdir -p "$HOME/.config/Code/User"

  # Backup existing configs that would conflict with stow (repo is source of truth)
  # Fresh Omarchy has regular files where dotfiles wants symlinks — backup then remove so stow can link
  echo "Backing up existing configs that conflict with repo (fresh Omarchy)..."
  BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$BACKUP_DIR"
  # All files/dirs that will be stowed on Linux
  CONFLICTS=(
    "$HOME/.config/nvim"
    "$HOME/.config/ghostty/config"
    "$HOME/.config/starship.toml"
    "$HOME/.config/tmux/tmux.conf"
    "$HOME/.config/Code/User/settings.json"
    "$HOME/.config/Code/User/keybindings.json"
    "$HOME/.zshrc"
    "$HOME/.ssh/config"
    "$HOME/.config/hypr"
    "$HOME/.config/omarchy"
    "$HOME/.gitconfig"
    "$HOME/.vimrc"
  )
  for f in "${CONFLICTS[@]}"; do
    if [[ -e "$f" && ! -L "$f" ]]; then
      echo "  Backing up $f -> $BACKUP_DIR/"
      mkdir -p "$BACKUP_DIR/$(dirname "${f#$HOME/}")"
      cp -a "$f" "$BACKUP_DIR/${f#$HOME/}"
      # Remove original so stow can create symlink
      rm -rf "$f"
    fi
  done
  if [[ -d "$BACKUP_DIR" ]] && [[ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]]; then
    rmdir "$BACKUP_DIR" 2>/dev/null || true
  else
    echo "  Backup saved to $BACKUP_DIR"
  fi

  echo "Applying symlinks with Stow (Linux)..."
  cd "$DOTFILES"
  # Use explicit package list so aerospace (macOS-only) is not stowed on Linux
  # shellcheck disable=SC2086
  stow -v $COMMON_PKGS $LINUX_PKGS

  # Re-create the Omarchy theme symlink the nvim package can't stow (it points
  # into per-machine omarchy state). No-op when omarchy state is absent (macOS).
  # Six levels: HOME/dotfiles/nvim/.config/nvim/lua/plugins -> HOME.
  if [[ -f "$HOME/.local/state/omarchy/current/theme/neovim.lua" ]]; then
    mkdir -p "$HOME/.config/nvim/lua/plugins"
    ln -snf "../../../../../../.local/state/omarchy/current/theme/neovim.lua" \
      "$HOME/.config/nvim/lua/plugins/theme.lua"
  fi

  # Set zsh as default shell if not already
  if [[ "$SHELL" != *"zsh"* ]] && command -v zsh >/dev/null 2>&1; then
    echo "Setting zsh as default shell (chsh)..."
    chsh -s "$(command -v zsh)" || true
  fi
fi

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

echo "Done. Packages installed: $COMMON_PKGS + OS-specific."
if [[ "$OS" != "Darwin" ]]; then
  echo "Hyprland: run 'hyprctl reload' to apply. Shell: 'omarchy restart shell' if needed."
fi
