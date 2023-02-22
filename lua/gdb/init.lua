local M = {}

M.default_options = {
	-- `boolean`. If `true` then asking for source file will not be asked.
	default_to_buf = true,
	-- `boolean`. If `true` then asking for binary file will not be asked.
	ask_binary = true,
}

M._binary_name = nil

M._gdb_mark = "Z"

-- User opts will override default options.
-- Any value not passed in will retain its default values
M.setup = function(user_opts)
	M.default_options = vim.tbl_extend("force", M.default_options, user_opts)
end


local function subscribe_to_buf_close_event(origin_buf, term_buf, src_buf)
	local events = {
		"BufUnload",
		"BufDelete"
	}

	vim.api.nvim_create_autocmd(events, {
		callback = function()
			local cur_win = vim.api.nvim_get_current_win()
			local cur_buf = vim.api.nvim_win_get_buf(cur_win)

			-- Makes sure that the buf to close is the same as the ones
			-- in the new tab
			local same_buf = cur_buf == term_buf or cur_buf == src_buf

			if same_buf then
				-- If `cur_win` is passed in this also includes the window where
				-- `:Debug` was called. So, both windows get closed. Setting it
				-- to `0` will close only the current buffer.
				vim.api.nvim_win_close(0, false)

				local pos = vim.api.nvim_buf_get_mark(origin_buf, M._gdb_mark)
				local line = pos[1]
				local col = pos[2]
				-- print(vim.inspect(pos))
				-- sets mark if it doesn't exist
				if line ~= 0 and col ~= 0 then
					vim.api.nvim_buf_set_mark(origin_buf, M._gdb_mark, line, col, {})
				else
					vim.api.nvim_buf_call(origin_buf, function()
						vim.cmd("normal! `" .. M._gdb_mark)
					end)

					vim.api.nvim_buf_del_mark(origin_buf, M._gdb_mark)
				end

			end
		end
	})
end

local function prompt(question)
	local input = vim.fn.input(question, '', "file")
	return input
end

local function setup_workspace()
	local origin_buf = vim.api.nvim_get_current_buf()
	local pos = vim.api.nvim_win_get_cursor(0)
	vim.api.nvim_buf_set_mark(origin_buf, M._gdb_mark, pos[1], pos[2], {})

	local cur_win = vim.api.nvim_get_current_win()
	local pos = vim.api.nvim_win_get_cursor(0)
	M._call_origin = {
		win_id = cur_win,
		pos = pos,
	}

	local file = nil
	if M.default_options.default_to_buf == false then
		file = prompt("Name of source file (defaults to current buffer if empty): ")
	else
		file = vim.fn.expand("%:p")
	end

	-- Need to find out a way to detect the binary.
	if M._binary_name == nil or M.default_options.ask_binary == false then
		M._binary_name = prompt("Name of binary to debug: ")
	end

	-- Creates a new tab with the source file
	vim.cmd("tabnew " .. file)

	-- Gets the window where the source file is displayed.
	local src_win = vim.api.nvim_get_current_win()
	local width = vim.api.nvim_win_get_width(src_win)
	local height = vim.api.nvim_win_get_height(src_win)

	local MIN_WIDTH = 140
	if width < MIN_WIDTH then
		vim.cmd("split")
	else
		vim.cmd("vsplit")
	end

	-- `term_win` is the window from splitting the screen
	local term_win = vim.api.nvim_get_current_win()

	-- I have no idea why this is reversed
	if width < MIN_WIDTH then
		-- Handle vsplit stuff here
		local size = math.floor(height * 0.50);
		vim.api.nvim_win_set_height(term_win, size)
	else
		-- Handle split here
		local size = math.floor(width * 0.35);
		vim.api.nvim_win_set_width(term_win, size)
	end

	-- gdb will run inside this buffer
	local buf_gdb = vim.api.nvim_create_buf(true, true)

	-- Place a buffer inside a window
	vim.api.nvim_win_set_buf(term_win, buf_gdb)
	local start_debugger = {
		cmd = "term",
		args = {
			"gdb",
			M._binary_name
		},
	}

	local buf_src = vim.api.nvim_win_get_buf(src_win)
	subscribe_to_buf_close_event(origin_buf, buf_gdb, buf_src)

	vim.cmd(start_debugger);
end

M.debug = function()
	setup_workspace()
end

return M
