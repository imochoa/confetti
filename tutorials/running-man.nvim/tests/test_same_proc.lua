local expect, eq = MiniTest.expect, MiniTest.expect.equality

local T = MiniTest.new_set()

T["same process"] = MiniTest.new_set()

T["same process"]["works-no-if-else"] = function()
  local x = 1 + 1
  MiniTest.expect.equality(x, 2)
end

T["same process"]["works"] = function()
  local x = 1 + 1
  MiniTest.expect.equality(x, 2)
end

T["same process"]["also works"] = function()
  local x = 2 + 2
  MiniTest.expect.equality(x, 4)
end

T["out of scope"] = function()
  local x = 3 + 3
  MiniTest.expect.equality(x, 6)
end

return T
