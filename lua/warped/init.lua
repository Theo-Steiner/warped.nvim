local Warped = {}
local colorbuddy = require("colorbuddy")
local utils = require("warped.utils")

local default_mapping = {
	-- text color
	white = "bright_white",
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
local adapt_colorscheme = function(theme_name, mapping)
	local Color = colorbuddy.Color
	-- see if is standard theme first (TODO: remove once standard themes are in github)
	local standard_module_name = "warped.standard_themes." .. theme_name:lower()
	local theme_colors = utils.try_require(standard_module_name)
	-- else check if is non-standard theme
	local module_name = "warped.themes." .. theme_name:lower()
	theme_colors = theme_colors or utils.try_require(module_name)
	if theme_colors then
		for vim_color, assigned_color in pairs(mapping) do
			local derived_color = theme_colors[assigned_color]
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
