local filename = vim.fn.expand("%:p")
print(filename)
print("Setting user command: `ReloadRunningMan`...")

vim.api.nvim_create_user_command("ReloadRunningMan", function()
  package.loaded["running-man"] = nil
  local running_man = require("running-man")
  running_man.setup({})
  running_man._develop()
end, {})

print("Setting key combination...")
vim.keymap.set("n", "<space><space><space>", "<cmd>ReloadRunningMan<CR>", { desc = "Reload Running Man plugin" })
