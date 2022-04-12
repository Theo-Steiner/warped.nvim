local M = {}

function M.extract_theme()
	-- get theme name from defaults api
	local handle = io.popen("defaults read dev.warp.Warp-Stable Theme")
	-- remove trailing newline and any special characters from theme name
	local theme_name = handle:read("*a"):sub(1, -2):gsub("[%p%c%s]", "")
	handle:close()
	return theme_name
end

function M.listen(settings)
	local fwatch = require("fwatch")
	local path = vim.fn.expand("~/Library/Preferences/dev.warp.Warp-Stable.plist")
	fwatch.watch(path, {
		on_event = function()
			local theme_name = M.extract_theme()
			vim.defer_fn(function()
				settings.onchange_callback(theme_name, settings.mapping)
			end, 100)
		end,
	})
end

return M
