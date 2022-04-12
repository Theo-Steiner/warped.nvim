local Warped = {}
local colorbuddy = require("colorbuddy")
local default_mapping = {
	-- text color
	white = "bright_white",
	-- responsible for errors, lua table keys, gitsigns delete
	red = "dark_red",
	-- Responsible for: git signs added, lua strings
	green = "bright_green",
	-- Responisble for <Component> / <html-tag> inner color gitsigns modified, lualine normal mode
	yellow = "dark_blue",
	-- selected color, link inside of a tag, "local" declaration
	blue = "dark_cyan",
	-- neo-tree folder color
	orange = "dark_yellow",
	aqua = "bright_blue",
	cyan = "dark_green",
	purple = "dark_magenta",
	violet = "bright_cyan",
	brown = "dark_white",
	seagree = "bright_red",
	turquoise = "bright_magenta",
	-- seems unimportant
	pink = "bright_yellow",
}

-- map vim colors to 16 terminal colors
local themes = require("warped.themes")
local adapt_colorscheme = function(theme_name, mapping)
	local Color = colorbuddy.Color
	local current_colors = themes[theme_name]
	if current_colors then
		for vim_color, assigned_color in pairs(mapping) do
			local derived_color = current_colors[assigned_color]
			Color.new(vim_color, derived_color or assigned_color)
		end
	end
	-- apply changes to the colorscheme
	Warped.apply()
end

function Warped.setup(settings)
	-- set defaults for settings if undefined
	settings = settings or {}
	settings.onchange_callback = settings.onchange_callback or adapt_colorscheme
	settings.color_mapping = settings.color_mapping or default_mapping
	-- setup colorbuddy
	colorbuddy.setup()
	local utils = require("warped.utils")
	-- call once to initialize without any colors
	local initial_theme_name = utils.extract_theme()
	settings.onchange_callback(initial_theme_name, settings.color_mapping)
	-- set up listener for subsequent theme adaptation
	utils.listen(settings)
end

function Warped.apply()
	colorbuddy.colorscheme("warped")
end

return Warped
