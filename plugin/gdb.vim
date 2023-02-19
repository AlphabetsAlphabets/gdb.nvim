" This value doesn't get overwritten if the user calls it
" luado require("gdb").setup({detect_binary = false}) 
command! Debug lua require("gdb").debug()
