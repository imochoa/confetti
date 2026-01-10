-- INFO: run with `:luafile %`
--  % -> "this file"

local filename = vim.fn.expand("%:p")
print(filename)

print("Setting runtimepaths...")
-- local buf_path = vim.api.nvim_buf_get_name(0)
local bufpath = vim.fn.expand("%:p")
local bufdir = vim.fn.expand("%:p:h")
local repodir = vim.fn.expand("%:p:h:h")

vim.opt.rtp:append(bufdir)
vim.opt.rtp:append(repodir)
vim.opt.rtp:append(repodir .. "/plugin")

-- runtime! plugin/plenary.vim
-- vim.cmd(string.format("runtime! %s/plugin/loadit.lua", repodir))
vim.cmd(string.format(":luafile %s/plugin/loadit.lua", repodir))
