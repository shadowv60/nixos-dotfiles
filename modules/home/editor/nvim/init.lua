-- new ui
require("vim._core.ui2").enable({})
-- config
require("config.options")
require("config.keymaps")
require("config.commands")
-- plugins
require("plugins.ui")
require("plugins.mini")
require("plugins.telescope")
require("plugins.treesitter")
require("plugins.lsp")
require("plugins.alpha")
require("plugins.harpoon")
require("plugins.persistence")
require("plugins.flash")
require("plugins.comment")
require("plugins.bufferline")
