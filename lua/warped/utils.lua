local M = {}

M.current_theme_name = nil
M.current_theme_colors = nil

function M.extract_theme()
	-- get theme name from defaults api
	local handle = io.popen("defaults read dev.warp.Warp-Stable Theme")
	-- remove trailing newline and make lower case
	local theme_name = handle:read("*a"):sub(1, -2):lower()
	handle:close()
	-- Custom themes are stored with a different format
	if theme_name:find("custom") then
		theme_name = theme_name:match("([^%/]+)%.ya*ml.*")
	end
	-- remove control, space and quote characters from theme name
	return theme_name:gsub('[%c%s"]', "")
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

function M.shallow_copy(table)
	local copy = {}
	for k, v in pairs(table) do
		copy[k] = v
	end
	return copy
end

function M.load_theme_colors(theme_name)
	local module_name = "warped.default_themes." .. theme_name
	-- attempt to load theme colors from default themes
	local theme_colors = M.try_require(module_name)
	if theme_colors then
		return theme_colors
	end
	-- check if theme already processed
	local processing_utils = require("warped.processing")
	local theme_path = processing_utils.get_cache_path() .. theme_name .. ".lua"
	local success, loaded_colors = pcall(dofile, theme_path)
	if success then
		return loaded_colors
	end
	-- generate theme modules based on .warp/themes directory and load newly generated module
	processing_utils.generate_theme_modules()
	success, loaded_colors = pcall(dofile, theme_path)
	if success then
		return loaded_colors
	else
		return nil
	end
end

-- utility function for "Warped" command
function M.get_theme_info()
	if M.current_theme_name == nil then
		return "Theme could not be determined."
	end
	if M.current_theme_colors == nil then
		return string.format("Detected theme: '%s' but could not load corresponding colors.", M.current_theme_name)
	end
	return string.format("Currently displaying theme based on: '%s'.", M.current_theme_name)
end

-- utility function for WarpedClean
function M.clean_cache()
	local cache_path = require("warped.processing").get_cache_path()
	os.execute("rm -rf " .. cache_path)
	vim.api.nvim_echo({ { "Cleared cache at " }, { cache_path } }, false, {})
end

function M.listen(config)
	local fwatch = require("fwatch")
	local path = vim.fn.expand("~/Library/Preferences/dev.warp.Warp-Stable.plist")
	M.apply_theme = function()
		M.current_theme_name = M.extract_theme()
		M.current_theme_colors = M.load_theme_colors(M.current_theme_name)
		config.onchange_callback(M.current_theme_name, M.current_theme_colors, config.color_mapping)
		vim.api.nvim_echo({ { "Applied theme: " }, { M.current_theme_name } }, false, {})
	end

	-- call apply theme deferred in listener
	fwatch.watch(path, {
		on_event = function()
			vim.defer_fn(M.apply_theme, 20)
		end,
	})

	return M.apply_theme
end

return M
