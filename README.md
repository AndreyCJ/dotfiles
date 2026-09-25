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

## Omarchy shell plugins

Omarchy plugins are installed by `bin/install.sh` and live in
`omarchy/.config/omarchy/plugins/`. Each one is referenced in three places,
and **all three must agree** or a fresh install comes up broken.

### Adding a plugin

1. Install it locally, which clones it into the plugins directory:

   ```bash
   omarchy plugin add https://github.com/owner/repo.git --enable --yes
   omarchy shell rescanPlugins
   ```

   The `id` is the `id` field in the plugin's `manifest.json`, not the
   repository name (e.g. `io.github.joshz7.afterglow`).

2. Add the clone URL to `OMARCHY_PLUGINS` in `bin/install.sh`, so the
   installer clones it on a fresh machine. The installer runs
   `omarchy plugin add --enable --yes` per entry and ignores failures, so a
   bad entry never aborts the install.

3. Add `omarchy/.config/omarchy/plugins/<id>/` to the plugin block in
   `.gitignore`. The checkout is managed by `omarchy plugin add`/`update`,
   not by git, so it must be ignored like every other plugin.

4. Reference the `id` in `omarchy/.config/omarchy/shell.json`, either as a
   bar widget in `bar.layout.left`/`center`/`right` (with any plugin
   settings inline) or in the top-level `plugins` array. If the plugin
   replaces a stock service, add that stock id to `disabledPlugins` too.

5. Restart the shell:

   ```bash
   omarchy restart shell
   ```

### Removing a plugin

The mirror image — miss any step and it comes back on the next install:

1. Remove it from the machine:

   ```bash
   omarchy plugin remove <id> --yes
   omarchy restart shell
   ```

2. Delete any `shell.json` references to the `id` — bar layout entries,
   `plugins` array entries, and `disabledPlugins` entries. Leaving a stale
   layout entry for a plugin that no longer exists will break the bar.

3. Remove the clone URL from `OMARCHY_PLUGINS` in `bin/install.sh`.

4. Remove `omarchy/.config/omarchy/plugins/<id>/` from `.gitignore`.

Nothing needs to change in `.stow-local-ignore` for plugin work: the `.git`
entry already covers the nested checkout that `omarchy plugin add` leaves
behind, which is what lets Stow symlink the plugins directory into place.
