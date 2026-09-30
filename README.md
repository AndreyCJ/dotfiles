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

## Themes

On Omarchy, the theme comes from Omarchy: it writes one palette out to every
app, and `bin/install.sh` links the Neovim half of it to
`~/.config/nvim/lua/plugins/theme.lua`.

Without Omarchy, the terminal owns it, and nothing in the config asks which
machine it is running on — the only question is whether an Omarchy theme
exists. So the same checkout works on macOS, on Arch with Omarchy, and on an
Arch box installed without it.

- **Neovim** follows the theme Ghostty is configured with, by name, through the
  map in `nvim/.config/nvim/lua/config/ghostty-theme.lua`. `Ayu` becomes
  `ayu-dark`, `Ayu Light` becomes `ayu-light`, and Flexoki's two names become
  `flexoki-dark` / `flexoki-light`. A theme that is not in the map falls back to
  the LazyVim default rather than to a wrong guess. Switching Ghostty to a theme
  worth matching by hand means adding a row there and the plugin providing that
  colorscheme to `lua/plugins/all-themes.lua`, so lazy can resolve the name.
  Re-apply inside a running Neovim with `:GhosttyTheme`.
- **Herdr** needs no help. `theme.name = "terminal"` in its config makes Herdr
  ask the outer terminal for its palette and use that everywhere, including the
  accent — so no accent is pinned here. It has to stay a theme name rather than
  a color list, because Herdr resolves color names against its own built-in X11
  table — a color set in this shared config would pin one machine's palette into
  every machine's UI.

### When the theme is reapplied

Ghostty is asked for its resolved config rather than queried live, so the same
theme applies over SSH, headless, or inside tmux or Herdr. It does mean the
answer is only as fresh as the last time something asked, which is one of:

| Trigger | When |
| --- | --- |
| Neovim startup | `VimEnter` |
| `FocusGained` | window or tab focus, throttled to once per 30s |
| `LazyReload` | after `:Lazy reload` |
| `:GhosttyTheme` | on demand |

`FocusGained` exists because a desktop appearance on a schedule flips at sunset
without touching any config file. It is not a timer: nothing runs while the
session sits idle, and the check is skipped entirely unless Ghostty is
configured with a `light:X,dark:Y` pair, since a single theme name resolves the
same way whatever the appearance is. If the resolved name matches the theme
already applied, nothing is reapplied.

A `light:X,dark:Y` pair is resolved through the desktop's appearance, which is
the one question Ghostty's own `+show-config` cannot answer — it reports the
pair verbatim and reads as light on a dark desktop. On macOS the appearance is
read from System Events, which is a GUI agent and reports what is actually in
effect; `AppleInterfaceStyle` cannot answer it, because with "Switch
automatically" set macOS derives the style from the time of day and never
writes the key. GNOME and KDE answer through `org.gnome.desktop.interface
color-scheme`. A desktop that reports neither is treated as dark, so give
Ghostty a single theme name on such a machine.

Herdr has a matching lag of its own, for the same reason from the other side:
it caches the outer terminal's palette on startup, so a palette that changed
underneath it is not picked up until the attached client is resized. Reloading
its config does not refresh it — `kill -WINCH <client-pid>` does.

## System packages

Each OS gets its packages from a plain text file at the repo root, so adding
one is a one-line edit rather than a change to the installer:

| OS | File | Read by |
| --- | --- | --- |
| macOS | `Brewfile` | `brew bundle` |
| Linux | `Pacfile` | `read_pacfile` in `bin/install.sh` |

`Pacfile` is one package per line. Blank lines and anything after a `#` are
ignored, so entries can be grouped under comments however you like. Only list
what you want on a machine — Omarchy already provides the kernel, boot chain,
PipeWire/Wayland plumbing, Hyprland core and the `omarchy-*` framework
packages.

Any name that is not in an enabled sync database is treated as AUR-only and
split out for `yay`, because pacman resolves its whole batch up front and
aborts everything on a single name it cannot find. The split depends only on
your repositories, not on what happens to be installed already, so a fresh
machine and an existing one take the same path. If `yay` is missing,
`bin/install.sh` warns and skips those names instead of failing.

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
