-- INFO: run with `:luafile %`
--  % -> "this file"

local filename = vim.fn.expand("%:p")
print(filename)

print("Setting runtimepaths...")
-- local buf_path = vim.api.nvim_buf_get_name(0)
local bufdir = vim.fn.expand("%:p:h")
local repodir = vim.fn.expand("%:p:h:h")

vim.opt.rtp:append(bufdir)
vim.opt.rtp:append(repodir)
vim.opt.rtp:append(repodir .. "plugin")
-- vim.cmd([[let &rtp.=','.getcwd()]])

-- vim.cmd(string.format("runtime! %s/plugin/loadit.lua", repodir))
-- vim.cmd(string.format(":luafile %s/plugin/loadit.lua", repodir))

-- Set up 'mini.test' only when calling headless Neovim (like with `make test`)
if #vim.api.nvim_list_uis() == 0 then
  print("no UI! set up tests...")
  -- Add 'mini.nvim' to 'runtimepath' to be able to use 'mini.test'
  -- Assumed that 'mini.nvim' is stored in 'deps/mini.nvim'
  -- vim.cmd("set rtp+=deps/mini.nvim")
  vim.opt.rtp:append(repodir .. "deps/mini.nvim")

  require("mini.test").setup()
else
  print("in UI! set up reload cmds")
  vim.api.nvim_create_user_command("ReloadRunningMan", function()
    package.loaded["running-man"] = nil
    local running_man = require("running-man")
    running_man.setup({})
    running_man._develop()
  end, {})

  print("Setting key combination...")
  vim.keymap.set("n", "<space><space><space>", "<cmd>ReloadRunningMan<CR>", { desc = "Reload Running Man plugin" })
end
