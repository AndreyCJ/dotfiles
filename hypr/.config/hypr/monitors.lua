-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

local host = io.popen("hostname"):read("*l") or os.getenv("HOSTNAME") or ""

if host == "pc" then
  -- Desktop (pc) setup
  hl.monitor({ output = "DP-1", mode = "1920x1080@144", position = "0x0", scale = 1 })
  hl.monitor({ output = "HDMI-A-2", mode = "1920x1080@70", position = "auto", scale = 1 })
else
  -- Laptop setup
  omarchy_monitor_scale = 1.1
  hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = 1 })
  hl.monitor({ output = "HDMI-A-2", mode = "1920x1080@144", position = "0x0", scale = 1 })
  hl.monitor({ output = "DP-1", mode = "preferred", position = "auto", scale = 1 })
end

  -- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
  -- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })
