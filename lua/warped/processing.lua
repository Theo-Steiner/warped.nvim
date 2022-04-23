M = {}

-- get a list of all yaml files from within a directory
local dir_lookup = function(dir)
	local handle, err = io.popen('find "' .. dir .. '" -type f')
	local paths = {}
	if handle then
		for file_path in handle:lines() do
			if file_path:match("%.ya*ml$") then
				table.insert(paths, file_path)
			end
		end
		handle:close()
	else
		print("Could read from directory: \n" .. dir .. "\n Failed with error: \n" .. err)
	end
	return paths
end

-- process theme.yaml files into a table of colors
local parse_file = function(file_path)
	local colors = ""
	local prefix = ""
	local lines, err = io.lines(file_path)
	if lines then
		for line in lines do
			if line:sub(1, 1) ~= "#" then
				if line:find("bright") then
					prefix = "bright_"
				elseif line:find("normal") then
					prefix = "normal_"
				else
					local colorname
					local colorvalue
					for str in line:gmatch("([^:]+)") do
						if colorname then
							if str:find("#") then
								colorvalue = str:gsub("%s+", "")
							elseif str:find("darker") then
								colorname = "bg"
								colorvalue = "'dark'"
							elseif str:find("lighter") then
								colorname = "bg"
								colorvalue = "'light'"
							end
						else
							colorname = str:gsub("%s+", "")
						end
					end
					if colorname and colorvalue then
						colors = string.format("%s \t%s%s = %s,\n", colors, prefix, colorname, colorvalue)
					end
				end
			end
		end
	else
		print("Could read from file: \n" .. file_path .. "\n Failed with error: \n" .. err)
	end
	return "return {\n" .. colors .. "}"
end

-- generate a theme's output name from its path (e.g. /path/to/my_theme.yaml -> my_theme.lua)
-- default themes currently drop underscores, and therefore need special processing (see process_output_name)
local generate_output_name = function(path)
	local theme_name = path:match("([^%/]+)%.ya*ml$")
	return theme_name .. ".lua"
end

local get_cache_path = function(path)
	return vim.fn.stdpath("cache") .. "/warped_generated_themes/"
end

-- get the path to where theme.lua files should be cached
M.get_cache_path = get_cache_path

-- Transform all installed themes into lua files and cache them
-- @param {string} dir_path - directory to search for theme.yaml files (default: "~/.warp/themes")
-- @param {string} output_path - directory to put theme.lua files (default: cache)
-- @param {function} process_output_name - post-processing for the theme's ouput names
function M.generate_theme_modules(dir_path, output_path, process_output_name)
	dir_path = dir_path or "~/.warp/themes"
	output_path = output_path or get_cache_path()
	process_output_name = process_output_name or function(output_name)
		return output_name
	end
	local theme_dir = vim and vim.fn.expand(dir_path) or dir_path
	local theme_paths = dir_lookup(theme_dir)
	for _, file_path in ipairs(theme_paths) do
		local colors = parse_file(file_path)
		local output_name = process_output_name(generate_output_name(file_path))
		os.execute("mkdir -p " .. output_path)
		local file, err = io.open(output_path .. output_name, "w")
		if file then
			file:write(colors)
			file:close()
		else
			print("Could not output theme module:\n" .. output_name .. "\n Failed with error: \n" .. err)
			return
		end
		if vim then
			vim.api.nvim_echo(
				{ { "Generated themes from " }, { dir_path }, { " output to: " }, { output_path } },
				false,
				{}
			)
		end
	end
end

return M
