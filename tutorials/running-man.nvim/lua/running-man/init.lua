local M = {}

-- Default configuration
M.config = {
  option1 = "default_value",
  option2 = true,
}

--- Setup function that users call
---@param user_config table Array. Default: { 'world' }.
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

--- Example function to be tested
---@param a number
---@param b number
---@return number
function M.add(a, b)
  print("running M.add()")
  return a + b
end

return M
