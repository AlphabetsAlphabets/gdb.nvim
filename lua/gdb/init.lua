-- Get the constants

local M = {}

M.default_options = {
	-- `boolean`. If `true` then asking for source file will not be asked.
	default_to_buf = true,
	-- `boolean`. If `true` then asking for binary file will not be asked.
	detect_binary = true,
}

-- User opts will override default options.
-- Any value not passed in will retain its default values
M.setup = function(user_opts)
	M.default_options = vim.tbl_extend("force", M.default_options, user_opts)
end

local function prompt(question)
	local input = vim.fn.input(question, '', "file")
	return input
end

-- TODO: Implement this
local function find_project_root()
end

local function setup_workspace()
	local file = nil
	if M.default_options.default_to_buf == false then
		file = prompt("Name of source file (defaults to current buffer if empty): ")
	else
		file = vim.fn.expand("%:p")
	end

	-- Need to find out a way to detect the binary.
	local binary = ''
	if M.default_options.detect_binary == false then
		binary = prompt("Name of binary to debug: ")
	else
		-- TODO: Auto find binary
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
			binary
		},
	}

	vim.cmd(start_debugger);
end

M.debug = function()
	setup_workspace()
end

return M
