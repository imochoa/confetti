local M = {}

local constants = require("confetti.constants")

-- There are two types of UIs for highlighting:
-- cterm	terminal UI (|TUI|)
-- gui	GUI or RGB-capable TUI ('termguicolors')

---@class GuiHighlight More info with 'help: highlight', 'help: highlight-args'
---@field guifg string|nil Text color (eg. "white", "#a89984" )
---@field guibg string|nil Background color (eg. "black", "#d79921" )
---@field altfont boolean|nil Tui highlight arg
---@field bold boolean|nil  Tui highlight arg
---@field inverse boolean|nil Flips bg & fg colors
---@field italic boolean|nil  Tui highlight arg
---@field nocombine boolean|nil  Tui highlight arg
---@field standout boolean|nil  Tui highlight arg
---@field strikethrough boolean|nil  Tui highlight arg
---@field undercurl boolean|nil  Tui highlight arg
---@field underdashed boolean|nil  Tui highlight arg
---@field underdotted boolean|nil  Tui highlight arg
---@field underdouble boolean|nil  Tui highlight arg
---@field underline boolean|nil  Tui highlight arg

--[[
Given an array of *bgcolors* with hex color values e.g. {"#cc241d", "#a89984", "#b16286"}, create new highlight groups for them and return them
--]]
---@param colors GuiHighlight[]
---@return string[] new_hl_groups
M.create_hl_groups = function(colors)
	local names = {}
	local gui_fields = {
		"altfont",
		"bold",
		"inverse",
		"italic",
		"nocombine",
		"standout",
		"strikethrough",
		"undercurl",
		"underdashed",
		"underdotted",
		"underdouble",
		"underline",
	}

	for i, c in pairs(colors) do
		-- name
		local n = "ConfettiHLGroup" .. i
		table.insert(names, n)
		vim.notify("Creating " .. n, constants.log_level)

		-- values
		local cmd_str = "highlight " .. n .. " "

		-- prepare command
		--TODO: default fg?
		if #(c.guifg or "") ~= 0 then
			cmd_str = cmd_str .. "guifg=" .. c.guifg .. " "
		end
		--TODO: default bg?
		if #(c.guibg or "") ~= 0 then
			cmd_str = cmd_str .. "guibg=" .. c.guibg .. " "
		end
		local gui_args = ""
		for _, f in pairs(gui_fields) do
			if c[f] or false then
				gui_args = gui_args .. f .. ","
			end
		end
		if #gui_args > 0 then
			gui_args = gui_args:sub(1, -2)
			cmd_str = cmd_str .. "gui=" .. gui_args
		else
			-- remove trailing space
			cmd_str = cmd_str:sub(1, -2)
		end

		-- create it
		vim.cmd(cmd_str)
	end

	return names
end

--[[
Given a set of *hl_groups*, delete them
--]]
---@param hl_groups string[]
---@return nil
M.remove_hl_groups = function(hl_groups)
	for _, hl_group in ipairs(hl_groups) do
		local cmd_str = "highlight clear " .. hl_group
		vim.cmd(cmd_str)
	end
end

return M
