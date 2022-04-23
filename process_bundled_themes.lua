local processing_utils = dofile("./lua/warped/processing.lua")
-- Warp's bundled themes for now are just formatted as lower case,
-- without the underscore present in custom themes, so we'll have to remove it manually here.
local process_output_name = function(output_name)
	return output_name:gsub("_", "")
end
processing_utils.generate_theme_module("./themes/warp_bundled", "./lua/warped/default_themes/", process_output_name)
