local gdb = require("gdb")

-- Use default options
gdb.setup({})
-- Expose `:Debug` command
vim.api.nvim_create_user_command("Debug", gdb.debug, {})
