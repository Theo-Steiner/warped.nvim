local Warped = {}

local colorbuddy = require("colorbuddy")
colorbuddy.setup()

local Color = colorbuddy.Color
-- map vim colors to 16 terminal colors
local themes = require("warped.themes")
local set_theme_colors = function(current_theme)
	local current_colors = themes[current_theme]
	if current_colors then
		-- white -> bright:white
		Color.new("white", current_colors.bright_white)

		-- red -> dark:red
		Color.new("red", current_colors.dark_red)

		-- pink -> bright:yellow
		Color.new("pink", current_colors.bright_yellow)

		-- Responsible for: git signs added
		-- green -> bright:green
		Color.new("green", current_colors.bright_green)

		-- Responisble for <Component> / <html-tag> color
		-- yellow -> dark:blue
		Color.new("yellow", current_colors.dark_blue)

		-- v-selection link inside of a tag
		-- blue -> dark:cyan
		Color.new("blue", current_colors.dark_cyan)

		-- aqua -> bright:blue
		Color.new("aqua", current_colors.bright_blue)

		-- cyan -> dark:green
		Color.new("cyan", current_colors.dark_green)

		-- purple -> dark:magenta
		Color.new("purple", current_colors.dark_magenta)

		-- violet -> bright:cyan
		Color.new("violet", current_colors.bright_cyan)

		-- orange -> dark:yellow
		Color.new("orange", current_colors.dark_yellow)

		-- brown -> dark:white
		Color.new("brown", current_colors.dark_white)

		-- seagreen -> bright:red
		Color.new("seagreen", current_colors.bright_red)

		-- turquoise -> bright:magenta
		Color.new("turquoise", current_colors.bright_magenta)
	end
	-- apply changes to the colorscheme
	colorbuddy.colorscheme("warped")
end

local set_warp_based_theme = function()
	-- get theme name from defaults api
	local handle = io.popen("defaults read dev.warp.Warp-Stable Theme")
	-- remove trailing newline and any special characters from theme name
	local theme_name = handle:read("*a"):sub(1, -2):gsub("[%p%c%s]", "")
	handle:close()
	set_theme_colors(theme_name)
end

local fwatch = require("fwatch")
local listen_for_theme_change = function()
	local path = vim.fn.expand("~") .. "/Library/Preferences/dev.warp.Warp-Stable.plist"
	fwatch.watch(path, {
		on_event = function()
			vim.defer_fn(set_warp_based_theme, 100)
		end,
	})
end

function Warped.setup()
	-- call once to initialize without any colors
	set_warp_based_theme()
	listen_for_theme_change()
end

return Warped
