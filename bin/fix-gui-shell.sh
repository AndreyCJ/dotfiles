#!/usr/bin/env bash

set -euo pipefail

# Diagnose why GUI-spawned terminals (Ghostty) may launch bash instead
# of the login shell that `chsh` already set in /etc/passwd.

# Ghostty resolves its default shell in this priority:
#   1. `command` config option (in ~/.config/ghostty/config)
#   2. the $SHELL environment variable (inherited from the parent session)
#   3. the login shell from /etc/passwd
# A session that was started BEFORE `chsh` still exports the OLD shell in
# $SHELL, so every new terminal inherits it (bash) and ignores the passwd
# entry (zsh). The fix is to start a fresh session by logging out/in.

uname_s="$(uname -s)"

# Determine the invested/effective shell for a fresh login.
if [[ "$uname_s" == "Darwin" ]] && command -v dscl >/dev/null 2>&1; then
  passwd_shell="$(dscl . -read "/Users/$(id -un)" UserShell 2>/dev/null | awk '{print $2}')"
else
  passwd_shell="$(getent passwd "$(id -un)" | cut -d: -f7)"
fi

env_shell="${SHELL:-}"
resolved_command="$(ghostty +show-config 2>/dev/null | sed -n 's/^command[[:space:]]*=[[:space:]]*//p' | head -n1)"

# Check whether the user actually set `command` in their ghostty config file(s),
# as opposed to Ghostty merely REPORTING the resolved default in +show-config.
user_command="$(grep -hE '^[[:space:]]*command[[:space:]]*=' \
  "$HOME/.config/ghostty/config" 2>/dev/null | sed -E 's/^[[:space:]]*command[[:space:]]*=[[:space:]]*//' | head -n1 || true)"

printf 'Login shell in passwd  : %s\n' "${passwd_shell:-<unknown>}"
printf 'SHELL env var          : %s\n' "${env_shell:-<unset>}"
printf 'Ghostty resolved shell : %s\n' "${resolved_command:-<unset>}"
echo

# A) An explicit `command` set in the ghostty config wins unconditionally.
if [[ -n "${user_command}" ]]; then
  if [[ -n "${passwd_shell}" ]] && [[ "$(basename "$user_command")" != "$(basename "$passwd_shell")" ]]; then
    echo "NOTE: ~/.config/ghostty/config explicitly sets 'command = $user_command'."
    echo "That ignores both \$SHELL and /etc/passwd. Either edit it to your intended"
    echo "shell, or remove the 'command' line so the login shell is used."
    exit 0
  fi
  echo "NOTE: ~/.config/ghostty/config sets 'command = $user_command', which matches"
  echo "your login shell. Nothing to fix."
  exit 0
fi

# B) The env var differs from passwd -> stale session, needs a re-login.
if [[ -n "${env_shell}" ]] &&
   [[ -n "${passwd_shell}" ]] &&
   [[ "$(basename "$env_shell")" != "$(basename "$passwd_shell")" ]]; then
  echo "MISMATCH: the current session still exports SHELL=$env_shell"
  echo "but your login shell is $passwd_shell."
  echo
  echo "This session was started BEFORE the shell change, so every new terminal"
  echo "inherits the old \$SHELL and launches bash instead of $passwd_shell."
  echo
  echo "Fix: start a fresh session so \$SHELL matches your login shell."
  echo
  if [[ "$uname_s" == "Linux" ]] && command -v omarchy >/dev/null 2>&1; then
    echo "  omarchy system logout      # log out and log back in"
    echo "  # or a full reboot:"
    echo "  omarchy system reboot"
  else
    echo "  Log out of your desktop session and log back in (or reboot)."
  fi
  echo
  echo "Verify afterwards:"
  echo "  ghostty +show-config | grep '^command'   # expect command = $passwd_shell"
  exit 1
fi

# C) All good.
echo "OK: the session's \$SHELL matches the login shell ($passwd_shell)."
echo "New GUI terminals (Ghostty) should launch $passwd_shell."
