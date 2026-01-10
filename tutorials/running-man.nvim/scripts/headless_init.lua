-- INFO: should be called from plugin root...
vim.cmd([[let &rtp.=','.getcwd()]])

-- vim.cmd(string.format("runtime! %s/plugin/loadit.lua", repodir))
-- vim.cmd(string.format(":luafile %s/plugin/loadit.lua", repodir))

-- Set up 'mini.test' only when calling headless Neovim (like with `make test`)
if #vim.api.nvim_list_uis() == 0 then
  print("no UI! set up tests...")
  -- Add 'mini.nvim' to 'runtimepath' to be able to use 'mini.test'
  -- Assumed that 'mini.nvim' is stored in 'deps/mini.nvim'
  vim.cmd("set rtp+=deps/mini.nvim")
  require("mini.test").setup()
end
