local Warped = {}
local utils = require("warped.utils")
Warped.colorbuddy = utils.try_require("colorbuddy")

-- map vim colors to 16 terminal colors
local adapt_colorscheme = function(_, theme_colors, mapping)
	theme_colors = theme_colors or {}
	for vim_color, assigned_color in pairs(mapping) do
		local derived_color = theme_colors[assigned_color]
		if derived_color then
			Warped.Color.new(vim_color, derived_color or assigned_color)
		end
	end
end

-- set up commands
local create_commands = function()
	vim.cmd([[command! Warped lua print(require("warped.utils").get_theme_info())]])
	vim.cmd([[command! WarpedGenerate lua require("warped.processing").generate_theme_modules()]])
	vim.cmd([[command! WarpedClean lua require("warped.utils").clean_cache()]])
end

function Warped.setup(config)
	-- set defaults for settings if undefined
	config = config or {}
	config.onchange_callback = config.onchange_callback or adapt_colorscheme
	config.color_mapping = config.color_mapping or require("warped.default_mapping")
	config.theme_config = config.theme_config or require("warped.default_theme_config")

	create_commands()

	-- setup colorbuddy if available
	if Warped.colorbuddy then
		Warped.colorbuddy.colorscheme("warped")
		local Color, colors, Group, groups, styles = Warped.colorbuddy.setup()
		Warped.Color = Color
		config.theme_config(Color, colors, Group, groups, styles)
	end

	-- call once to initialize without any colors
	local initial_theme_name = utils.extract_theme()
	local theme_colors = utils.load_theme_colors(initial_theme_name)
	config.onchange_callback(initial_theme_name, theme_colors, config.color_mapping)

	-- Save the current theme name for theme info
	utils.current_theme_name = initial_theme_name
	utils.current_theme_colors = theme_colors

	-- set up listener for subsequent theme adaptation
	utils.listen(config)
end

return Warped
