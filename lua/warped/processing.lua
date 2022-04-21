M = {}

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
						colors = string.format("%s %s%s = %s,", colors, prefix, colorname, colorvalue)
					end
				end
			end
		end
	else
		print("Could read from file: \n" .. file_path .. "\n Failed with error: \n" .. err)
	end
	return "return {" .. colors .. "}"
end

local generate_output_name = function(path)
	local theme_name = path:match("([^%/]+)%.ya*ml$")
	return theme_name .. ".lua"
end

function M.get_cache_path()
	return vim.fn.stdpath("cache") .. "/warped_generated_themes/"
end

function M.generate_theme_module(dir_path)
	dir_path = dir_path or "~/.warp/themes"
	local theme_dir = vim.fn.expand(dir_path)
	local theme_paths = dir_lookup(theme_dir)
	for _, file_path in ipairs(theme_paths) do
		local colors = parse_file(file_path)
		local output_name = generate_output_name(file_path)
		local cache_path = M.get_cache_path()
		os.execute("mkdir -p " .. cache_path)
		local file, err = io.open(cache_path .. output_name, "w")
		if file then
			file:write(colors)
			file:close()
		else
			print("Could not output theme module:\n" .. output_name .. "\n Failed with error: \n" .. err)
		end
	end
end

return M
