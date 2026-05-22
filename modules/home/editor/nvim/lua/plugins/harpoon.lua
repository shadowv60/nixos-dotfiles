vim.pack.add({
    "https://github.com/nvim-lua/plenary.nvim",
    { src = "https://github.com/ThePrimeagen/harpoon", version = "harpoon2" },
})

local harpoon = require("harpoon")
harpoon:setup()

vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end, { desc = "Harpoon: Add file" })
vim.keymap.set("n", "<leader>e", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon: Quick Menu" })
vim.keymap.set("n", "<leader>p", function() harpoon:list():prev() end, { desc = "Harpoon: Previous" })
vim.keymap.set("n", "<leader>n", function() harpoon:list():next() end, { desc = "Harpoon: Next" })

vim.keymap.set("n", "<leader>l", function()
    local conf = require("telescope.config").values
    local themes = require("telescope.themes")
    local file_paths = {}
    for _, item in ipairs(harpoon:list().items) do
        table.insert(file_paths, item.value)
    end
    require("telescope.pickers").new(themes.get_ivy({
        prompt_title = "Harpoon Working List",
    }), {
        finder = require("telescope.finders").new_table({ results = file_paths }),
        previewer = conf.file_previewer({}),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, _)
            local actions = require("telescope.actions")
            local action_state = require("telescope.actions.state")
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                if selection then
                    vim.cmd("edit " .. selection[1])
                end
            end)
            return true
        end,
    }):find()
end, { desc = "Telescope: Harpoon list" })
