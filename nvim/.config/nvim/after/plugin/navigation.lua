-- Oil.nvim
local ok, oil = pcall(require, "oil")
if ok then
    oil.setup({
        default_file_explorer = true,
        view_options = {
            show_hidden = true,
        },
        float = {
            padding = 2,
            max_width = 60,
            max_height = 20,
        },
    })
end

-- FZF-Lua
local ok2, fzf = pcall(require, "fzf-lua")
if ok2 then
    fzf.setup({
        winopts = {
            height = 0.85,
            width = 0.80,
            preview = {
                layout = "vertical",
            },
        },
    })
end
