vim.pack.add({
    "https://github.com/ellisonleao/gruvbox.nvim",
    "https://github.com/nvim-tree/nvim-web-devicons",
    "https://github.com/nvim-lualine/lualine.nvim",
})

require("gruvbox").setup({
    -- optional: contrast = "hard" | "soft" | "" (default)
})
vim.o.background = "dark" -- or "light"
vim.cmd.colorscheme("gruvbox")

-- lualine
local custom_gruvbox = require('lualine.themes.gruvbox')
require('lualine').setup {
  options = { theme = custom_gruvbox },
  ...
}
