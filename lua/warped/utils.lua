local M = {}

function M.extract_theme()
	-- get theme name from defaults api
	local handle = io.popen("defaults read dev.warp.Warp-Stable Theme")
	-- remove trailing newline and any special characters from theme name
	local theme_name = handle:read("*a"):sub(1, -2):gsub("[%p%c%s]", "")
	handle:close()
	return theme_name
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
	local module_name = "warped.themes." .. theme_name:lower()
	-- attempt to load theme colors from module if no module available
	return M.try_require(module_name)
end

function M.listen(settings)
	local fwatch = require("fwatch")
	local path = vim.fn.expand("~/Library/Preferences/dev.warp.Warp-Stable.plist")
	fwatch.watch(path, {
		on_event = function()
			local theme_name = M.extract_theme()
			local theme_colors = M.load_theme_colors(theme_name)
			vim.defer_fn(function()
				settings.onchange_callback(theme_colors, theme_name, settings.color_mapping)
			end, 100)
		end,
	})
end

return M
