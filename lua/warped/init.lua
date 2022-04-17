local Warped = {}
local utils = require("warped.utils")
local colorbuddy = utils.try_require("colorbuddy")

local default_mapping = {
	background = "background",
	foreground = "foreground",
	-- text color
	white = "normal_white",
	black = "normal_black",
	-- responsible for errors, lua table keys, gitsigns delete
	red = "normal_red",
	-- Responsible for: git signs added, lua strings
	green = "bright_green",
	-- Responisble for <Component> / <html-tag> inner color gitsigns modified, lualine normal mode
	yellow = "normal_blue",
	-- selected color, link inside of a tag, "local" declaration
	blue = "normal_cyan",
	-- neo-tree folder color
	orange = "normal_yellow",
	aqua = "bright_blue",
	cyan = "normal_green",
	purple = "normal_magenta",
	violet = "bright_cyan",
	brown = "normal_white",
	seagree = "bright_red",
	turquoise = "bright_magenta",
	-- seems unimportant
	pink = "bright_yellow",
}

-- map vim colors to 16 terminal colors
local adapt_colorscheme = function(theme_colors, _theme_name, mapping)
	local Color = colorbuddy.Color
	if theme_colors then
		for vim_color, assigned_color in pairs(mapping) do
			local derived_color = theme_colors[assigned_color]
			Color.new(vim_color, derived_color or assigned_color)
		end
		Warped.apply(theme_colors["bg"] == "light")
	else
		-- re-apply colorscheme nonetheless
		Warped.apply()
	end
end

function Warped.setup(settings)
	-- set defaults for settings if undefined
	settings = settings or {}
	settings.onchange_callback = settings.onchange_callback or adapt_colorscheme
	settings.color_mapping = settings.color_mapping or default_mapping

	-- setup colorbuddy
	if colorbuddy then
		colorbuddy.setup()
	end

	-- call once to initialize without any colors
	local initial_theme_name = utils.extract_theme()
	local theme_colors = utils.load_theme_colors(initial_theme_name)
	settings.onchange_callback(theme_colors, initial_theme_name, settings.color_mapping)

	-- set up listener for subsequent theme adaptation
	utils.listen(settings)
end

function Warped.apply(light)
	colorbuddy.colorscheme("warped", light)
end

return Warped
