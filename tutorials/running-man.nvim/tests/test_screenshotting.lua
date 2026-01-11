local expect, eq = MiniTest.expect, MiniTest.expect.equality

-- Create (but not start) child Neovim object
local child = MiniTest.new_child_neovim()

-- Define main test set of this file
local T = MiniTest.new_set({
  hooks = {
    -- This will be executed before every (even nested) case
    pre_case = function()
      -- Restart child process with custom 'init.lua' script
      child.restart({ "-u", "scripts/headless_init.lua" })
      child.lua([[M = require('running-man')]])
    end,
    post_once = child.stop,
  },
})

T["screenshotting"] = MiniTest.new_set()

-- Make parametrized tests. This will create three copies of each case

-- Use arguments from test parametrization
T["screenshotting"]["works"] = function(buf_id, lines)
  -- Directly modify some options to make better test
  child.o.lines, child.o.columns = 10, 20
  child.bo.readonly = false

  -- Execute Lua code without returning value
  -- child.lua("M.set_lines(...)", { buf_id, lines })

  -- Test screen state. On first run it will automatically create reference
  -- screenshots with text and look information in predefined location. On
  -- later runs it will compare current screenshot with reference. Will throw
  -- informative error with helpful information if they don't match exactly.
  expect.reference_screenshot(child.get_screenshot())
end

-- Return test set which will be collected and execute inside `MiniTest.run()`
return T
