M = {}

-- in case of error, stop the file watcher and display a message
local handle_err = function(err, fs_event)
	-- detach file watcher
	fs_event:stop()
	-- display error
	vim.api.nvim_echo({ { "Warped.nvim filewatcher error: " }, { err } }, false, {})
end

-- initiate a file watcher that executes a callback when the specified file is changed
function M.initiate(file_path, on_change_callback)
	local file_watcher = vim.loop.new_fs_event()
	---@diagnostic disable-next-line: unused-local
	local callback = vim.schedule_wrap(function(err, fname, events)
		if err then
			handle_err(err, file_watcher)
		else
			-- For some reason the callback is not called repeatedly, unless I detach and reattach the watcher.
			file_watcher:stop()
			on_change_callback()
			M.initiate(file_path, on_change_callback)
		end
	end)
	-- attach file watcher
	file_watcher:start(file_path, {}, callback)
end

return M
