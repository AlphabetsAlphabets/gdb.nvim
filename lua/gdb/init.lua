-- Get the constants

local M = {}

-- `boolean`. If `true` then prompt asking for source file will not be asked.
local GDB_DEFAULT_TO_BUF = vim.g.GDB_DEFAULT_TO_BUF

-- `string`. The name of the binary. If set to an empty string or is `nil` prompt for binary name will appear.
local GDB_BINARY_NAME = vim.g.GDB_BINARY_NAME

M.debug = function()
	local completion = "file"
	local file = nil
	local prompt = ""

	if GDB_DEFAULT_TO_BUF == false then
		-- Tab completion does not work
		prompt = "Name of source file (defaults to current buffer if empty): "
		file = vim.fn.input(prompt, '', completion)
	else
		file = vim.fn.expand("%:p")
	end

	local binary = GDB_BINARY_NAME
	if binary == '' or binary == nil then
		prompt = "Name of binary to debug: "
		binary = vim.fn.input(prompt, '', completion)
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
		local size = math.floor(width * 0.20);
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
			binary
		},
	}

	vim.cmd(start_debugger);
end

return M
