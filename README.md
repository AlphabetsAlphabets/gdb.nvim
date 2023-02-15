# gdb.nvim
Super simple GDB integration with Neovim. This is mainly for C++. Contributions are welcome.

# Installation
You can use whichever package manager you prefer. In `packer.nvim` you can choose either option listed
1. use 'AlphabetsAlphabets/gdb.nvim'
2. use 'https://github.com/AlphabetsAlphabets/gdb.nvim'

# Configuration
There are currently two vairables gdb.nvim works with.
1. `GDB_DEFAULT_TO_BUF`. `boolean`, if `true` then prompt asking for source file will not be asked.
2. `GDB_BINARY_NAME`. `string`, the name of the binary. If set to an empty string or is `nil` prompt for binary name will appear.

# Usage
The command `:Debug` has been exposed. Since keymaps are personal I decided not to give it a mapping. I prefer just calling the command itself.

# Contributing
1. There isn't a solid or concrete instruction for contributing, but feel free to contribute to it :D.
2. Anything can be discussed. If you feel something is irrelevant or unneeded, feel free to do so.

The general guideline for contributing (at least for now) is to make fork, make your changes, submit a PR.
