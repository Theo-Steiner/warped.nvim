local Warped = {}
local utils = require("warped.utils")
Warped.colorbuddy = utils.try_require("colorbuddy")

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
local adapt_colorscheme = function(_, theme_colors, mapping)
	if theme_colors then
		for vim_color, assigned_color in pairs(mapping) do
			local derived_color = theme_colors[assigned_color]
			Warped.Color.new(vim_color, derived_color or assigned_color)
		end
		Warped.apply(theme_colors["bg"] == "light")
	end
end

function Warped.setup(config)
	-- set defaults for settings if undefined
	config = config or {}
	config.onchange_callback = config.onchange_callback or adapt_colorscheme
	config.color_mapping = config.color_mapping or default_mapping

	-- setup colorbuddy if available
	if Warped.colorbuddy then
		Warped.colorbuddy.setup()
		Warped.Color = Warped.colorbuddy.Color
	end

	-- call once to initialize without any colors
	local initial_theme_name = utils.extract_theme()
	local theme_colors = utils.load_theme_colors(initial_theme_name)
	config.onchange_callback(initial_theme_name, theme_colors, config.color_mapping)

	-- set up listener for subsequent theme adaptation
	utils.listen(config)
end

function Warped.apply(light)
	Warped.colorbuddy.colorscheme("warped", light)
end

return Warped
