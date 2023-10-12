local M = {}

-- There are two types of UIs for highlighting:
-- cterm	terminal UI (|TUI|)
-- gui	GUI or RGB-capable TUI ('termguicolors')

---@class GuiHighlight More info with 'help: highlight', 'help: highlight-args'
---@field guifg string Text color (eg. "white", "#a89984" )
---@field guibg string Background color (eg. "black", "#d79921" )
---@field gui string TUI highlight arguments (*bold* *underline* *undercurl* *underdouble* *underdotted* *underdashed* *inverse* *italic* *standout* *strikethrough* *altfont* *nocombine*)

--[[
Take the inputs and convert them to usable highlight group inputs
--]]
---@param args string[]
---@return GuiHighlight
M.parse_input = function(args)
	return {}
end

--[[
Given an array of *bgcolors* with hex color values e.g. {"#cc241d", "#a89984", "#b16286"}, create new highlight groups for them and return them
--]]
---@param bgcolors string[]
---@return string[] new_hl_groups
M.create_new_hl_groups = function(bgcolors)
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
		vim.notify("Found " .. #filtered_hl_groups .. " groups", vim.log.levels.TRACE)
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
