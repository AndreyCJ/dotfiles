# Dotfiles

My configuration files, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Supported OSes

- **macOS**
- **Arch Linux (Omarchy)**

## Installation

```bash
git clone git@github.com:AndreyCJ/dotfiles.git ~/Dotfiles
~/Dotfiles/bin/install.sh
```

The install script installs system dependencies, sets up Oh My Zsh, and
applies all config symlinks with Stow. It detects your OS automatically.

### Manual (explicit Stow)

If you'd rather handle Stow yourself:

```bash
cd ~/Dotfiles
stow .
```

To apply only a subset:

```bash
cd ~/Dotfiles
stow git nvim starship tmux ghostty ...
```

After stowing, close and reopen your terminal for the new shell config to
take effect.
