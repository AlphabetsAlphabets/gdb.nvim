-- Get the constants

local M = {}

M.options = {
	-- `boolean`. If `true` then asking for source file will not be asked.
	default_to_buf = true,

	-- `boolean`. If `true` then asking for binary file will not be asked.
	detect_binary = true,
}

-- This function doesn't actually do anything.
M.setup = function(user_opts)
	for k, v in pairs(user_opts) do
		M.options[k] = v
	end
end

local function create_prompts()
	local file = nil
	local binary = nil
	local completion = "file"
	local prompt = ""

	if M.options.default_to_buf == false then
		prompt = "Name of source file (defaults to current buffer if empty): "
		file = vim.fn.input(prompt, '', completion)
	else
		file = vim.fn.expand("%:p")
	end

	if M.options.detect_binary == false then
		prompt = "Name of binary to debug: "
		binary = vim.fn.input(prompt, '', completion)
	end

	return file, binary
end

local function create_splits()
	local file, binary = create_prompts()

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

M.debug = function()
	create_splits()
end

return M
