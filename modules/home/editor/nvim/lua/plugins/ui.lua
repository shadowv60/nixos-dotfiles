vim.pack.add({
	"https://github.com/shaunsingh/nord.nvim",
    "https://github.com/nvim-tree/nvim-web-devicons",
    "https://github.com/nvim-lualine/lualine.nvim",
})

-- lua line
local custom_nord = require'lualine.themes.nord'
require('lualine').setup {
  options = { theme  = custom_nord },
  ...
}
