vim.pack.add({
    "https://github.com/akinsho/bufferline.nvim",
})

require("bufferline").setup({
    options = {
        mode = "buffers",
        always_show_bufferline = false,
    }
})

vim.keymap.set("n", "<S-h>", ":bprev<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<S-l>", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bd", ":bd<CR>", { desc = "Close buffer" })
