local M = {}

function M.extract_theme()
	-- get theme name from defaults api
	local handle = io.popen("defaults read dev.warp.Warp-Stable Theme")
	-- remove trailing newline and any special characters from theme name
	local theme_name = handle:read("*a"):sub(1, -2):lower()
	handle:close()
	if theme_name:find("custom") then
		theme_name = theme_name:match("([^%/]+)%.ya*ml.*")
	end
	return theme_name:gsub("[%c%s]", "")
end

-- pcall wrapper around require
function M.try_require(module_path)
	local success, lib = pcall(require, module_path)
	if success then
		return lib
	end
	--module failed to load
	return nil
end

function M.load_theme_colors(theme_name)
	local module_name = "warped.themes." .. theme_name
	-- attempt to load theme colors from module if no module available
	return M.try_require(module_name)
end

function M.listen(config)
	local fwatch = require("fwatch")
	local path = vim.fn.expand("~/Library/Preferences/dev.warp.Warp-Stable.plist")
	fwatch.watch(path, {
		on_event = function()
			local theme_name = M.extract_theme()
			local theme_colors = M.load_theme_colors(theme_name)
			vim.defer_fn(function()
				config.onchange_callback(theme_name, theme_colors, config.color_mapping)
			end, 100)
		end,
	})
end

return M
