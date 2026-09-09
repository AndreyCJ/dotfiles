-- Change the default Omarchy look'n'feel.

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
--
--
hl.config({
  general = {
    gaps_in = 4,
    gaps_out = 8,
    border_size = 2,

    -- Change to niri-like side-scrolling layout.
    -- layout = "scrolling",
  },

  decoration = {
    rounding_power = 4,
    rounding = 8,

    -- The 0.05 gap is what marks the focused window.
    active_opacity = 0.95,
    inactive_opacity = 0.90,

    -- Translucency without blur makes text unreadable over these wallpapers.
    blur = {
      enabled = true,
      size = 3,
      passes = 3,
      brightness = 0.8,
      contrast = 0.9,
      new_optimizations = true
    },

    shadow = {
      enabled = true,
      range = 20,
      render_power = 4,
      color = "rgba(19151099)",
      color_inactive = "rgba(19151066)",
    },
  },
})

hl.animation({
  enabled = true,
  leaf = "workspaces",
  speed = 5,
  bezier = "easeOutQuint",
  style = "slide",
})
