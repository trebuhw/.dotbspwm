-- map leader
vim.g.mapleader = " "
local keymap = vim.keymap

local function opts(desc)
    return { silent = true, noremap = true, desc = desc }
end

-- General
keymap.set("n", "<leader>a", "gg<S-v>G", opts("Select all"))
keymap.set("v", "<", "<gv", opts("Indent left"))
keymap.set("v", ">", ">gv", opts("Indent right"))

-- Window
keymap.set("n", "<leader>m", ":Alpha<cr>", opts("Menu"))

-- Tab bindings
keymap.set("n", "<leader>t", ":tabnew<cr>", opts("New tab"))
keymap.set("n", "<leader>x", ":tabclose<cr>", opts("Close tab"))
keymap.set("n", "<leader>j", ":tabnext<cr>", opts("Next tab"))
keymap.set("n", "<leader>k", ":tabprevious<cr>", opts("Previous tab"))

-- Buffer navigation
keymap.set("n", "<Tab>", ":bnext<cr>", opts("Next buffer"))
keymap.set("n", "<S-Tab>", ":bprevious<cr>", opts("Previous buffer"))
keymap.set("n", "<leader>q", ":bd<cr>", opts("Close buffer"))

-- Split generation
keymap.set("n", "<leader>v", ":vsplit", opts("Vertical split"))
keymap.set("n", "<leader>s", ":split", opts("Horizontal split"))

-- Resize splits
keymap.set("n", "<C-Left>", ":vertical resize +3<cr>", opts("Resize left"))
keymap.set("n", "<C-Right>", ":vertical resize -3<cr>", opts("Resize right"))

-- Oil.nvim
keymap.set("n", "<leader>e", function()
    require("oil").toggle_float()
end, opts("Explorer"))

-- fzf-lua
keymap.set("n", "<leader>ff", "<cmd>FzfLua files<cr>", opts("Find files"))
keymap.set("n", "<leader>fw", "<cmd>FzfLua live_grep<cr>", opts("Find word"))
keymap.set("n", "<leader>fh", "<cmd>FzfLua help_tags<cr>", opts("Find help"))
keymap.set("n", "<leader>fc", function()
    require("fzf-lua").files({
        cwd = vim.fn.stdpath("config"),
    })
end, opts("Find config"))

-- Git
keymap.set("n", "<leader>gg", ":vertical Git<cr>", opts("Git status"))
keymap.set("n", "<leader>gc", "<cmd>FzfLua git_branches<cr>", opts("Git branches"))

-- Preview/Format
keymap.set("n", "<leader>pp", ":MarkdownPreviewToggle<cr>", opts("Preview markdown"))
keymap.set("n", "<leader>pf", function()
    if vim.fn.executable("prettier") == 1 then
        vim.cmd("!prettier --write " .. vim.fn.shellescape(vim.fn.expand("%")))
    else
        vim.notify("Prettier not found. Install with: npm install -g prettier", vim.log.levels.ERROR)
    end
end, opts("Format with Prettier"))
