-- Change the default Omarchy look'n'feel.
-- https://wiki.hypr.land/Configuring/Basics/Variables/#general

hl.config({
  general = {
    -- gaps_in = 4, -- 4
    -- gaps_out = 8,-- 8
    border_size = 2,
    allow_tearing = false,
    resize_on_border = true,
  },

  scrolling = {
    focus_fit_method = 1,
    follow_focus = true,
    follow_min_visible = 0.3,
    explicit_column_widths = "0.49, 0.98",
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
    rounding = 12, -- 8

    active_opacity = 0.97,
    inactive_opacity = 0.95,

    blur = {
      enabled = true,
      size = 4,
      passes = 2,
      brightness = 0.8,
      contrast = 0.9,
      new_optimizations = true
    },

    shadow = {
      enabled = true,
      range = 6,
      render_power = 2,
      -- color = "rgba(19191099)",

      color = "rgba(219, 108, 79, 0.03)", -- orange
      -- color = "rgba(191, 193, 224, 0.02)", -- blue
      color_inactive = "rgba(00000050)", -- MacOS style shadow

      -- color = "rgba(20203099)",
      -- color_inactive = "rgba(19151066)",
      --
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

