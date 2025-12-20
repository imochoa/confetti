describe("confetti", function()
	before_each(function()
		-- Reset confetti state before each test
		package.loaded["confetti"] = nil
		package.loaded["confetti.constants"] = nil
		package.loaded["confetti.utils"] = nil
		package.loaded["confetti.hllogic"] = nil
	end)

	it("can be required", function()
		local confetti = require("confetti")
		assert.is_not_nil(confetti)
	end)

	it("has a setup function", function()
		local confetti = require("confetti")
		assert.is_function(confetti.setup)
	end)

	it("has a highlight_at_cursor function", function()
		local confetti = require("confetti")
		assert.is_function(confetti.highlight_at_cursor)
	end)

	it("has a clear_highlights function", function()
		local confetti = require("confetti")
		assert.is_function(confetti.clear_highlights)
	end)

	it("can be setup with default config", function()
		local confetti = require("confetti")
		local result = confetti.setup()
		assert.is_not_nil(result)
	end)

	it("can be setup with empty config", function()
		local confetti = require("confetti")
		local result = confetti.setup({})
		assert.is_not_nil(result)
	end)

	it("can be setup with custom colors", function()
		local confetti = require("confetti")
		local result = confetti.setup({
			colors = {
				{ guifg = "black", guibg = "white" },
				{ guifg = "white", guibg = "black" },
			},
		})
		assert.is_not_nil(result)
	end)
end)
