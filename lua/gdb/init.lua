-- Get the constants

-- `boolean`. If `true` then prompt asking for source file will not be asked.
local GDB_DEFAULT_TO_BUF = vim.g.GDB_DEFAULT_TO_BUF

-- `string`. The name of the binary. If set to an empty string or is `nil` prompt for binary name will appear.
local GDB_BINARY_NAME = vim.g.GDB_BINARY_NAME

local function Debug()
	local file = nil
	if GDB_DEFAULT_TO_BUF == false then
		-- Tab completion does not work
		file = vim.fn.input("Name of source file (defaults to current buffer if empty): ")
	else
		file = vim.fn.expand("%:p")
	end

	local binary = GDB_BINARY_NAME
	if binary == '' or binary == nil then
		binary = vim.fn.input("Name of binary to debug: ")
	end

	-- Creates a new tab with the source file
	vim.cmd("tabnew " .. file)

	-- Gets the window where the source file is displayed.
	-- This is a variable because I want to detect the event where
	-- `term_win` is closed, and have the whole tab go with it
	local src_win = vim.api.nvim_get_current_win()

	-- Create the buffer where the terminal will run
	vim.cmd("vsplit")

	-- Gets the window created by the call to `vim.cmd("vsplit")`
	local term_win = vim.api.nvim_get_current_win()

	vim.api.nvim_win_set_width(term_win, 95)
	vim.api.nvim_win_set_option(term_win, "winfixheight", true)
	vim.api.nvim_win_set_option(term_win, "winfixwidth", true)

	-- Creates the buffer that is gonna be in the window
	local buf_gdb = vim.api.nvim_create_buf(true, true)

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

local exports = { debug = Debug }

return exports
