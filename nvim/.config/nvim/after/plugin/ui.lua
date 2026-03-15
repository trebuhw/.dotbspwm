-- Colorscheme
vim.cmd.colorscheme("github_dark_default")

-- Lualine
local ok, lualine = pcall(require, "lualine")
if ok then
    lualine.setup({
        options = {
            theme = "auto",
            component_separators = "",
            section_separators = "",
        },
    })
end

-- Bufferline
local ok2, bufferline = pcall(require, "bufferline")
if ok2 then
    bufferline.setup({})
end

-- Alpha (dashboard)
local ok3, alpha = pcall(require, "alpha")
if ok3 then
    local dashboard = require("alpha.themes.dashboard")
    dashboard.section.header.val = {
        "                                                     ",
        "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
        "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
        "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
        "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
        "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
        "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
        "                                                     ",
        "Keymap                                               ",
        "                                                     ",
        "  Find File: Space+ff      ||    Find Word: Space+fw ",
        " Create Tab: Space+t       ||    Close Tab: Space+x  ",
        "   Next Tab: Space+j       ||     Prev Tab: Space+k  ",
        "Next Buffer: Tab           ||  Prev Buffer: Shift+Tab",
        "Split Horiz: Space+s       ||   Split Vert: Space+v  ",
        "      Files: Space+e       ||         Git: Space+g   ",
        "                                                     ",
    }
    dashboard.section.buttons.val = {
        dashboard.button("e", "  New file", ":ene <BAR> startinsert<CR>"),
        dashboard.button("f", "  Find file", ":FzfLua files<CR>"),
        dashboard.button("r", "  Recent files", ":FzfLua oldfiles<CR>"),
        dashboard.button("q", "  Quit", ":qa<CR>"),
    }
    alpha.setup(dashboard.config)
end

-- Indent blankline
local ok4, ibl = pcall(require, "ibl")
if ok4 then
    ibl.setup({
        indent = { char = "│" },
        scope = { enabled = false },
    })
end

-- Colorizer
local ok5, colorizer = pcall(require, "colorizer")
if ok5 then
    colorizer.setup()
end

-- Transparent
local ok6, transparent = pcall(require, "transparent")
if ok6 then
    transparent.setup({})
end

-- Which-key
local ok7, wk = pcall(require, "which-key")
if ok7 then
    wk.setup({
        icons = {
            breadcrumb = "»",
            separator = "→",
            group = "+",
        },
        win = {
            border = "rounded",
        },
    })
    wk.add({
        { "<leader>f", group = "Find" },
        { "<leader>g", group = "Git" },
        { "<leader>p", group = "Preview" },
    })
end
