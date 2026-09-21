-- Change the default Omarchy look'n'feel.
-- https://wiki.hypr.land/Configuring/Basics/Variables/#general

hl.config({
  general = {
    gaps_in = 4, -- 4
    gaps_out = 8,-- 8
    border_size = 2,
  },

  scrolling = {
    focus_fit_method = 1,
    follow_focus = true,
    follow_min_visible = 0.3,
  },

  input = {
    focus_on_close = 2,
    follow_mouse = 1,
    mouse_refocus = false,
  },


  dwindle = {
    preserve_split = true
  },

  decoration = {
    rounding_power = 4,
    rounding = 8, -- 8

    active_opacity = 0.92,
    inactive_opacity = 0.91,

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
      range = 6,
      render_power = 2,
      -- color = "rgba(19191099)",
      color = "rgba(20203099)",
      color_inactive = "rgba(19151066)",
    },

  },
})

hl.window_rule({
  workspace = "2 silent",
  match = {
    class = "Interagent-dev-linux-amd64"
  },
})

-- hl.animation({
--   enabled = true,
--   leaf = "workspaces",
--   speed = 5,
--   bezier = "easeOutQuint",
--   style = "slide",
-- })

