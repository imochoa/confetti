local M = {}

-- Default configuration
M.config = {
  option1 = "default_value",
  option2 = true,
}

--- Setup function that users call
---@return nil
function M.setup(user_config)
  M.config = vim.tbl_deep_extend("force", M.config, user_config or {})
  -- Initialize your plugin here
end

-- vim.api.nvim_create_user_command("PresentStart", function()
--   -- Easy Reloading
--   package.loaded["present"] = nil
--
--   require("present").start_presentation()
-- end, {})

-- Your plugin functions
---@return nil
function M._develop()
  print("developing!")
end

return M
