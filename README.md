# gdb.nvim
Super simple GDB integration with Neovim. This is mainly for C++. Contributions are welcome.

# Usage
The command `:Debug` has been exposed. Since keymaps are personal I decided not to give it a mapping. I prefer just calling the command itself.

# Todo
- [ ] Identify project root based on common files (C++ for now).
- [ ] Setup variables in order to skip the input sections.
  - Find out if there is a way to auto detect the name of the binary
  - Maybe instead of running gdb with the binary the binary can be specified AFTER getting into GDB.
