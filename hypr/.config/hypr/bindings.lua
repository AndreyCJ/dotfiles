-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- o.bind("SUPER + TAB", "Alt-Tab switcher", hl.dsp.global("omarchy-alttab:next"), { repeating = true })





-- Vim-style window navigation. The arrow keys keep working as duplicates.
o.bind("SUPER + H", "Focus on left window", hl.dsp.focus({ direction = "l" }))
o.rebind("SUPER + J", "Focus on below window", hl.dsp.focus({ direction = "d" }))
o.rebind("SUPER + K", "Focus on above window", hl.dsp.focus({ direction = "u" }))
o.rebind("SUPER + L", "Focus on right window", hl.dsp.focus({ direction = "r" }))

o.bind("SUPER + SHIFT + H", "Swap window to the left", hl.dsp.window.swap({ direction = "l" }))
o.bind("SUPER + SHIFT + J", "Swap window down", hl.dsp.window.swap({ direction = "d" }))
o.bind("SUPER + SHIFT + K", "Swap window up", hl.dsp.window.swap({ direction = "u" }))
o.bind("SUPER + SHIFT + L", "Swap window to the right", hl.dsp.window.swap({ direction = "r" }))

o.bind("SUPER + ALT + H", "Move window to group on left", hl.dsp.window.move({ into_group = "l" }))
o.bind("SUPER + ALT + J", "Move window to group on bottom", hl.dsp.window.move({ into_group = "d" }))
o.rebind("SUPER + ALT + K", "Move window to group on top", hl.dsp.window.move({ into_group = "u" }))
o.bind("SUPER + ALT + L", "Move window to group on right", hl.dsp.window.move({ into_group = "r" }))

o.bind("SUPER + SHIFT + ALT + H", "Move workspace to left monitor", hl.dsp.workspace.move({ monitor = "l" }))
o.bind("SUPER + SHIFT + ALT + J", "Move workspace to down monitor", hl.dsp.workspace.move({ monitor = "d" }))
o.bind("SUPER + SHIFT + ALT + K", "Move workspace to up monitor", hl.dsp.workspace.move({ monitor = "u" }))
o.bind("SUPER + SHIFT + ALT + L", "Move workspace to right monitor", hl.dsp.workspace.move({ monitor = "r" }))

-- Moved out of the way of the navigation keys above.
o.bind("SUPER + SEMICOLON", "Toggle window split", hl.dsp.layout("togglesplit"))
o.bind("SUPER + ALT + SEMICOLON", "Toggle workspace layout", "omarchy-hyprland-workspace-layout-toggle")

-- Full width: maximizes the window over the workspace, hiding the others.
o.rebind("SUPER + ALT + F", "Full width", hl.dsp.window.fullscreen({ mode = "maximized" }))

-- Scrolling-layout full width. colresize only resizes the focused column, so the
-- other windows stay put and the workspace is still scrollable. Takes over from
-- "Tiled full screen", whose fullscreen_state dispatcher no-ops in this build.
-- colresize is implemented only by the scrolling layout, so this does nothing
-- on dwindle.
o.rebind("SUPER + CTRL + F", "Full width (scrolling)", hl.dsp.layout("colresize +conf"))

-- Reclaim / for the help menus. SUPER + SHIFT + SLASH ("Passwords") was
-- unreachable anyway: on a US layout Super + / yields keysym 'slash' with only
-- SUPER held, and Super + Shift + / yields 'question' -- neither could match it.
-- Reach the others with `omarchy launch 1password` and
-- `omarchy hyprland monitor scaling <n>`.
hl.unbind("SUPER + SHIFT + SLASH")
o.rebind("SUPER + SLASH", "Keybindings", "omarchy-menu-keybindings")
o.rebind("SUPER + ALT + SLASH", "Tmux keybindings", "omarchy-menu-tmux-keybindings")

-- Move the notification binds off ','. The SHIFT+comma and SHIFT+ALT+comma ones
-- could never fire: on a US layout Shift+, emits keysym 'less', not 'comma', and
-- Hyprland matches the keysym and the modmask exactly. 'backslash' is unshifted,
-- so all five keep their modifiers and become reachable.
hl.unbind("SUPER + comma")
hl.unbind("SUPER + SHIFT + comma")
hl.unbind("SUPER + CTRL + comma")
hl.unbind("SUPER + ALT + comma")
hl.unbind("SUPER + SHIFT + ALT + comma")
o.bind("SUPER + backslash", "Dismiss last notification", "omarchy-shell notifications dismissOne")
o.bind("SUPER + SHIFT + backslash", "Dismiss all notifications", "omarchy-shell notifications dismissAll")
o.bind("SUPER + CTRL + backslash", "Toggle silencing notifications", "omarchy-toggle-notification-silencing")
o.bind("SUPER + ALT + backslash", "Invoke last notification", "omarchy-shell notifications invokeLast")
o.bind("SUPER + SHIFT + ALT + backslash", "Open notification history", "omarchy-shell notifications showHistory")

-- -- bindings.lua: Hyprland & Omarchy bindings for omalt-tab window switcher

hl.unbind("SUPER + TAB")
hl.unbind("SUPER + SHIFT + TAB")
o.bind("SUPER + TAB", "Focus on next window", hl.dsp.window.cycle_next(), { repeating = true })
o.bind("SUPER + SHIFT + TAB", "Focus on previous window", hl.dsp.window.cycle_next({ next = false }), { repeating = true })

hl.unbind("ALT + TAB")
hl.unbind("ALT + SHIFT + TAB")

local omalt_tab = os.getenv("HOME") .. "/.config/omarchy/plugins/io.github.codesmith28.omalt-tab/hypr/bindings.lua"
local f = io.open(omalt_tab, "r")
if f then
  f:close()
  dofile(omalt_tab)
end
