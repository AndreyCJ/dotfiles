-- Theme for machines that do not get one from Omarchy.
--
-- On Omarchy, bin/install.sh links the theme Omarchy generates into
-- lua/plugins/theme.lua, and that is the whole story. Everywhere else this
-- module follows the theme Ghostty is configured with, so Neovim matches the
-- terminal it runs in instead of the LazyVim default.
--
-- Nothing here branches on the OS. The question the cascade below asks is
-- "does an Omarchy theme exist?", which is true on Arch with Omarchy, false on
-- macOS, and false on an Arch box installed without it -- one code path answers
-- all three, and a machine that moves between them needs no edit here.
--
-- Ghostty is asked for its resolved config rather than queried live, so the
-- answer does not depend on what the outer terminal happens to be: the same
-- theme applies over SSH, headless, or inside tmux or Herdr. The cost is that
-- a palette switched from some other terminal is only picked up when something
-- asks again: on the next start, on regaining focus, or through
-- :GhosttyTheme.
local M = {}

local DEFAULT_COLORSCHEME = "tokyonight"

-- The last colorscheme applied, and whether Ghostty's theme is a light/dark
-- pair. A single theme name resolves the same way whatever the appearance is,
-- so there is nothing to re-check and `applied` is only compared when the pair
-- flag says the appearance can change the answer.
local applied = nil
local pair_theme = false

-- FocusGained arrives on every alt-tab, and each check costs a
-- `ghostty +show-config` plus an appearance probe. This is not a timer: the
-- comparison only happens inside that event, so an idle session runs nothing.
local last_check = 0
local RECHECK_SECONDS = 30

-- Ghostty theme name to Neovim colorscheme. Keys are normalized, so "Ayu
-- Light" and "ayu-light" both reach "ayulight". Ghostty's "Ayu" is Ayu Dark's
-- palette (#0b0e14 on #bfbdb6) and "Ayu Light" is Ayu Light's, so the names
-- carry across unchanged; a theme that is only loosely related still lands on
-- the closest one of the three. Flexoki's names carry across as well, but to
-- the two explicit variants rather than the single `flexoki.lua`, which picks
-- its palette from Neovim's own background and would be a second answer to a
-- question this module has already answered from the desktop appearance.
--
-- Add a row here when a new Ghostty theme is worth matching by hand. Anything
-- missing falls back to the LazyVim default rather than to a wrong guess.
local COLORSCHEMES = {
	ayu = "ayu-dark",
	ayulight = "ayu-light",
	ayumirage = "ayu-mirage",
	flexokidark = "flexoki-dark",
	flexokilight = "flexoki-light",
}

local function normalize(name)
	return (name:gsub("[^%a]", ""):lower())
end

-- Which side of a "light:X,dark:Y" theme pair is on screen. Ghostty resolves
-- the pair from the desktop's appearance, and prints the pair itself either
-- way, so the choice has to be made here too.
--
-- macOS answers through System Events, GNOME and KDE desktops through
-- gsettings. Anything else has no cheap answer, so assume dark; a single theme
-- name is the unambiguous way to configure a machine that lands in that case.
local function appearance()
	local is_macos = vim.fn.has("mac") == 1 or vim.fn.has("macunix") == 1

	if is_macos and vim.fn.executable("osascript") == 1 then
		-- System Events is a GUI agent, so it reports the appearance actually in
		-- effect. AppleInterfaceStyle cannot answer this: with "Switch
		-- automatically" set, macOS derives the style from the time of day and
		-- never writes the key, which then reads as light all evening. Ghostty's
		-- own +show-config is blind the same way, so it cannot be used either.
		local ok, answer = pcall(vim.fn.system, {
			"osascript",
			"-e",
			'tell application "System Events" to tell appearance preferences to get dark mode',
		})
		if ok then
			answer = answer:lower()
			if answer:find("true", 1, true) == 1 then
				return "dark"
			end
			if answer:find("false", 1, true) == 1 then
				return "light"
			end
		end

		-- Older macOS, or automation refused: fall back to the preference, which
		-- only exists while the appearance is Dark.
		if vim.fn.executable("defaults") == 1 then
			local style = vim.trim(vim.fn.system({ "defaults", "read", "-g", "AppleInterfaceStyle" }))
			return style:lower():find("dark", 1, true) and "dark" or "light"
		end
	end

	if not is_macos and vim.fn.executable("gsettings") == 1 then
		local ok, value = pcall(vim.fn.system, { "gsettings", "get", "org.gnome.desktop.interface", "color-scheme" })
		if ok then
			value = value:lower()
			if value:find("prefer-dark", 1, true) then
				return "dark"
			end
			if value:find("prefer-light", 1, true) then
				return "light"
			end
		end
	end

	return "dark"
end

-- The lines of `ghostty +show-config`, or {} when Ghostty is missing or fails.
-- Given a callback the probe runs through vim.system, which keeps a ~20ms
-- subprocess off the startup path; without one it runs inline and returns the
-- lines.
local function ghostty_config(callback)
	if vim.fn.executable("ghostty") ~= 1 then
		return callback and callback({}) or {}
	end

	if callback and vim.system then
		vim.system({ "ghostty", "+show-config" }, { text = true, timeout = 5000 }, function(result)
			-- Handed to us on a fast event, where the API cannot be called, so
			-- the work moves onto the main loop.
			vim.schedule(function()
				callback(result.code == 0 and vim.split(result.stdout, "\n", { plain = true }) or {})
			end)
		end)
		return
	end

	local ok, lines = pcall(vim.fn.systemlist, { "ghostty", "+show-config" })
	local resolved = ok and vim.v.shell_error == 0 and lines or {}
	if callback then
		callback(resolved)
	end
	return resolved
end

-- The theme Ghostty is configured with, or nil. A pair is reported verbatim
-- whichever way round it was written, so the variant is picked from the
-- desktop's appearance rather than from the order.
local function configured_theme(lines)
	local value
	for _, line in ipairs(lines) do
		-- A key printed more than once resolves last-wins, so the final
		-- occurrence is the one Ghostty itself would apply.
		local theme = line:match("^%s*theme%s*=%s*(.+)%s*$")
		if theme then
			value = vim.trim(theme)
		end
	end

	-- Every return gives the pair flag, so the caller never has to treat nil as
	-- false: a single-value return here would otherwise hand back nil for it.
	if value == nil or value == "" then
		return nil, false
	end

	local variants = {}
	for item in value:gmatch("[^,]+") do
		local mode, name = item:match("^%s*([%a]+)%s*:%s*(.+)%s*$")
		if mode then
			variants[mode:lower()] = vim.trim(name)
		end
	end

	if next(variants) ~= nil then
		local wanted = appearance()
		return variants[wanted] or variants.dark or variants.light, true
	end

	return value, false
end

local function ghostty_colorschemes(lines)
	local theme, is_pair = configured_theme(lines)
	pair_theme = is_pair
	local mapped = theme and COLORSCHEMES[normalize(theme)]
	return mapped and { mapped } or { DEFAULT_COLORSCHEME }
end

-- Where Omarchy writes the theme it generates. bin/install.sh links this into
-- lua/plugins/theme.lua, but that link is created once during install, so a
-- machine whose link is missing or predates the current theme still has the
-- file behind it.
local function omarchy_theme_file()
	local state = vim.env.XDG_STATE_HOME
	if state == nil or state == "" then
		state = vim.fs.joinpath(vim.fn.expand("~"), ".local", "state")
	end
	return vim.fs.joinpath(state, "omarchy", "current", "theme", "neovim.lua")
end

-- A theme spec is the list Omarchy generates: theme plugins to install, plus
-- the LazyVim entry carrying the colorscheme to apply.
local function colorschemes_in(spec)
	local names = {}
	if type(spec) ~= "table" then
		return names
	end

	for _, entry in ipairs(spec) do
		if type(entry) == "table" and type(entry.opts) == "table" and entry.opts.colorscheme then
			table.insert(names, entry.opts.colorscheme)
		end
	end

	return names
end

-- Colorschemes from Omarchy, best first. Empty wherever Omarchy is not
-- installed, which is what lets the rest of the module decide.
local function omarchy_colorschemes()
	local names = {}

	local ok, spec = pcall(require, "plugins.theme")
	if ok then
		vim.list_extend(names, colorschemes_in(spec))
	end

	local file = omarchy_theme_file()
	if vim.fn.filereadable(file) == 1 then
		local chunk = loadfile(file)
		if chunk then
			pcall(function()
				vim.list_extend(names, colorschemes_in(chunk()))
			end)
		end
	end

	return vim.fn.uniq(names)
end

-- Applies the first colorscheme that loads, then re-sources the transparency
-- pass the Omarchy path re-sources too, so switching does not leave the
-- background opaque. A name whose plugin is not installed fails here and the
-- next candidate is tried, which is what keeps a stale or unresolvable theme
-- from leaving Neovim without a colorscheme at all.
local function apply_first(names)
	-- neovim-ayu is lazy in all-themes.lua, so at VimEnter its colors/ files are
	-- not on the runtimepath yet and :colorscheme would not find them. lazy's
	-- colorscheme loader pulls in whichever unloaded plugin owns colors/<name>,
	-- and is a no-op for a name it does not know. A config without lazy is left
	-- with the plain :colorscheme, which the pcall below reports on.
	local has_lazy, mod = pcall(require, "lazy.core.loader")
	-- The error message lands in `mod` when the require fails, so the module is
	-- taken from `mod` only once `has_lazy` says it is a table. Written this way
	-- rather than nil-ing a variable that briefly holds a string, which a type
	-- checker reads as `string|table` at every use below.
	local loader = has_lazy and mod or nil

	for _, name in ipairs(names) do
		if loader then
			pcall(loader.colorscheme, name)
		end
		if pcall(vim.cmd.colorscheme, name) then
			applied = name
			local transparency = vim.fs.joinpath(vim.fn.stdpath("config"), "plugin", "after", "transparency.lua")
			if vim.fn.filereadable(transparency) == 1 then
				pcall(vim.cmd.source, transparency)
			end
			return name
		end
	end
end

-- Every colorscheme worth trying, best first. Synchronous, for headless checks
-- and for a theme switch that cannot wait.
function M.colorschemes()
	local names = omarchy_colorschemes()
	if #names > 0 then
		return names
	end

	return ghostty_colorschemes(ghostty_config())
end

function M.apply()
	-- Counts as a check, so the focus right after startup does not probe again.
	last_check = os.time()
	-- The Omarchy sources are a require and one small file read, so they are
	-- resolved inline and cost nothing.
	local names = omarchy_colorschemes()
	if #names > 0 then
		return apply_first(names)
	end

	ghostty_config(function(lines)
		apply_first(ghostty_colorschemes(lines))
	end)
end

-- A machine on an automatic appearance flips at sunset without touching any
-- config file, so the theme applied at startup goes stale. Regaining focus is
-- the cheapest moment to notice: nothing runs while the session sits idle.
local function recheck()
	if not pair_theme or not applied or os.difftime(os.time(), last_check) < RECHECK_SECONDS then
		return
	end
	last_check = os.time()

	ghostty_config(function(lines)
		local names = ghostty_colorschemes(lines)
		-- Only the first candidate is compared; the rest are fallbacks for a theme
		-- that fails to load, not what the terminal is showing.
		if names[1] == applied then
			return
		end
		apply_first(names)
	end)
end

function M.setup()
	vim.api.nvim_create_autocmd("VimEnter", {
		desc = "Match the terminal theme when Omarchy has not set one",
		callback = function()
			M.apply()
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "LazyReload",
		desc = "Re-match the terminal theme after a Lazy reload",
		callback = function()
			M.apply()
		end,
	})

	vim.api.nvim_create_autocmd("FocusGained", {
		desc = "Follow the terminal theme when the desktop appearance changes",
		callback = recheck,
	})

	vim.api.nvim_create_user_command("GhosttyTheme", function()
		M.apply()
	end, { desc = "Re-apply the theme the terminal is configured with" })
end

return M
