local expect, eq = MiniTest.expect, MiniTest.expect.equality

-- Create (but not start) child Neovim object
local child = MiniTest.new_child_neovim()

-- Define main test set of this file
local T = MiniTest.new_set({
  hooks = {
    -- This will be executed before every (even nested) case
    pre_case = function()
      -- Restart child process with custom 'init.lua' script
      -- child.restart({ "-u", "scripts/minimal_init.lua" })
      child.restart({ "-u", "scripts/headless_init.lua" })
      child.lua([[M = require('running-man')]])
    end,
    post_once = child.stop,
  },
})

T["in child"] = MiniTest.new_set()

-- T["set_lines()"] = MiniTest.new_set({ parametrize = { {}, { 0, { "a" } }, { 0, { 1, 2, 3 } } } })

T["in child"]["works"] = function()
  -- Execute Lua code inside child process, get its result and compare with
  -- expected result
  eq(child.lua_get([[M.add(2, 3)]]), 5)
end

return T
