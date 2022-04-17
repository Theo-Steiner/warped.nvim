local dir_lookup = function(dir)
	local handle = io.popen('find "' .. dir .. '" -type f')
	local paths = {}
	for file_path in handle:lines() do
		if file_path:match("%.yaml$") then
			table.insert(paths, file_path)
		end
	end
	handle:close()
	return paths
end

local parse_file = function(file_path)
	local colors = ""
	local prefix = ""
	for line in io.lines(file_path) do
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
	return "return {" .. colors .. "}"
end

local generate_output_name = function(path)
	local theme_name = path:match("([^/]+).yaml$"):gsub("_", "")
	return theme_name .. ".lua"
end

local theme_paths = dir_lookup("./themes/standard")
for _, file_path in ipairs(theme_paths) do
	local colors = parse_file(file_path)
	local output_name = generate_output_name(file_path)
	local file = io.open("./lua/warped/themes/" .. output_name, "w")
	file:write(colors)
	file:close()
end
