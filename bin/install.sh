#!/usr/bin/env bash

set -e

DOTFILES="$HOME/Dotfiles"

source "$DOTFILES"

echo "Applying macOS settings..."
"$DOTFILES/macos/defaults.sh"

echo "Installing Homebrew..."

if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "Installing packages..."

brew bundle --file="$DOTFILES/Brewfile"

echo "Installing Oh My Zsh..."

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

echo "Creating config directories..."

mkdir -p "$HOME/.config"
mkdir -p "$HOME/.ssh"

echo "Applying symlinks with Stow..."

cd "$DOTFILES"

stow .

envsubst < "$DOTFILES/wakatime/.wakatime.cfg.template" > "$DOTFILES/wakatime/.wakatime.cfg"

echo "Done."
