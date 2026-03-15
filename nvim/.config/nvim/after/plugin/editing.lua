-- Autopairs
local ok, autopairs = pcall(require, "nvim-autopairs")
if ok then
    autopairs.setup({})
end

-- Autolist (markdown lists)
local ok2, autolist = pcall(require, "autolist")
if ok2 then
    autolist.setup({})
    vim.keymap.set("i", "<CR>", "<CR><cmd>AutolistNewBullet<cr>")
    vim.keymap.set("n", "o", "o<cmd>AutolistNewBullet<cr>")
    vim.keymap.set("n", "O", "O<cmd>AutolistNewBulletBefore<cr>")
end

-- Render-markdown
local ok3, render_md = pcall(require, "render-markdown")
if ok3 then
    render_md.setup({})
end

-- Markdown-preview
vim.g.mkdp_filetypes = { "markdown" }
vim.defer_fn(function()
    pcall(vim.cmd, "call mkdp#util#install()")
end, 100)
