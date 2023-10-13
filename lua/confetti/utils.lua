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
---@field inverse boolean|nil  Tui highlight arg
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
Applies default values to GuiHighlight objs
--]]
---@param obj table
---@return GuiHighlight
M.instantiate_guihl = function(obj)
	--TODO: clean up unique args
	--TODO: only keep true values in tui
	return {
		guifg = obj.guifg or "black",
		guibg = obj.guibg or "yellow",
		gui = obj.gui,
	}
end

--[[
Given an array of *bgcolors* with hex color values e.g. {"#cc241d", "#a89984", "#b16286"}, create new highlight groups for them and return them
--]]
---@param bgcolors string[]
---@return string[] new_hl_groups
M.create_new_hl_groups = function(bgcolors)
	--TODO: remove this...
	local new_hl_groups = {}

	for i, v in pairs(bgcolors) do
		local hl_group_name = "ConfettiHLGroup" .. i
		local cmd_str = "highlight " .. hl_group_name .. " guibg=" .. v .. " gui=underline,bold guifg=black"
		-- guibg?
		vim.cmd(cmd_str)
		-- vim.notify(cmd_str, log_level)
		table.insert(new_hl_groups, hl_group_name)
	end

	return new_hl_groups
end

M.parse_inputs = function(objs)
	local custom_hex_colors = {}
	local existing_hl_groups = {}
	for _, el in ipairs(hl_groups) do
		if type(el) ~= "string" or #el == 0 then
			vim.notify("Ignoring invalid input: <" .. tostring(el) .. ">", vim.log.levels.ERROR)
		elseif el:sub(1, 1):lower() == "#" then
			-- Was a color!
			table.insert(custom_hex_colors, el)
		elseif constants.nvim_global_hl_groups[el] ~= nil then
			-- Was an existing highlight group
			table.insert(existing_hl_groups, el)
		else
			vim.notify("Ignoring unknown color/highlight group: <" .. el .. ">", vim.log.levels.ERROR)
		end
	end
end

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
		if #(c.guifg or "") ~= 0 then
			cmd_str = cmd_str .. "guifg=" .. c.guifg .. " "
		end
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
		vim.notify("Running " .. cmd_str)
		P(cmd_str)
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

--[[
Search the buffer for a *pattern* and apply *hl_group* to it
--]]
M._filter_hl_groups = function(hl_groups)
	local filtered_hl_groups = {}
	for k, v in pairs(hl_groups) do
		-- if v["fg"] and v["bg"] then
		-- if v["guifg"] and v["guibg"] then -- NO MATCHES!
		-- if v["ctermfg"] and v["ctermbg"] then -- just 2 matches?
		if v["ctermbg"] then -- 5 matches
			table.insert(filtered_hl_groups, k)
		end
	end

	if #filtered_hl_groups == 0 then
		vim.notify("No hl groups passed the filter!", vim.log.levels.ERROR)
	else
		table.sort(filtered_hl_groups)
		vim.notify("Found " .. #filtered_hl_groups .. " groups", constants.log_level)
	end

	return filtered_hl_groups
end

-- --[[
-- Given an array of *bgcolors* with hex color values e.g. {"#cc241d", "#a89984", "#b16286"}, create new highlight groups for them and return them
-- --]]
-- M._create_new_hl_groups = function(bgcolors)
-- 	local new_hl_groups = {}
--
-- 	for i, v in pairs(bgcolors) do
-- 		local hl_group_name = "ConfettiHLGroup" .. i
-- 		local cmd_str = "highlight " .. hl_group_name .. " guibg=" .. v .. " gui=underline,bold"
-- 		-- guibg?
-- 		vim.cmd(cmd_str)
-- 		vim.notify(cmd_str, log_level)
-- 		table.insert(new_hl_groups, hl_group_name)
-- 	end
--
-- 	return new_hl_groups
-- end
--
-- --[[
-- Given a set of *hl_groups*, delete them
-- --]]
-- M._remove_hl_groups = function(hl_groups)
-- 	for _, hl_group in ipairs(hl_groups) do
-- 		local cmd_str = "highlight clear " .. hl_group
-- 		vim.cmd(cmd_str)
-- 	end
-- end

return M
