-- Change the default Omarchy look'n'feel.

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
--
--
hl.config({
  general = {
    -- No gaps between windows or borders.
    gaps_in = 4,
    gaps_out = 4,
    border_size = 0,

    -- Change to niri-like side-scrolling layout.
    -- layout = "scrolling",
  },

  decoration = {
    rounding_power = 4,
    rounding = 8,

    -- The 0.05 gap is what marks the focused window.
    active_opacity = 0.98,
    inactive_opacity = 0.85,

    -- Translucency without blur makes text unreadable over these wallpapers.
    blur = {
      enabled = true,
      size = 6,
      passes = 2,
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
