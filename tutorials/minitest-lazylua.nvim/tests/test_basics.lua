local T = MiniTest.new_set()

local expect, eq = MiniTest.expect, MiniTest.expect.equality

T["works"] = function()
	local x = 1 + 1
	if x ~= 2 then
		error("`x` is not equal to 2")
	end
end

-- T["works-no-if-else"] = function()
-- 	local x = 1 + 1
-- 	MiniTest.expect.equality(x, 2)
-- end
--
-- T["big scope"] = new_set()
--
-- T["big scope"]["works"] = function()
-- 	local x = 1 + 1
-- 	MiniTest.expect.equality(x, 2)
-- end
--
-- T["big scope"]["also works"] = function()
-- 	local x = 2 + 2
-- 	MiniTest.expect.equality(x, 4)
-- end
--
-- T["out of scope"] = function()
-- 	local x = 3 + 3
-- 	MiniTest.expect.equality(x, 6)
-- end
return T
