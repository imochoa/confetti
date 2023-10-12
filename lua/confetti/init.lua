local M = {}

local constants = require("confetti.constants")
local utils = require("confetti.utils")
local hllogic = require("confetti.hllogic")

--[[
Private cache
--]]
local custom_hl_groups = {}
local usable_hl_groups = {}
local current_hl_group_idx = 1

--[[
Private Functions
--]]

--[[
Get the next hl group and update the global tracker
--]]
---@return string hl_group
local next_hl_group = function()
	--@return string
	local hl_group = usable_hl_groups[current_hl_group_idx]
	current_hl_group_idx = current_hl_group_idx % #usable_hl_groups + 1
	return hl_group
end

--[[
Reload this module (for debugging)
--]]
M.reload = function()
	require("plenary.reload").reload_module("confetti")
	vim.notify("Reloaded Confetti")
end

--[[
Function to bind
--]]
M.highlight_at_cursor = function()
	if #(usable_hl_groups or {}) == 0 then
		-- setup() has not been called or did not create hl groups! Use the defaults
		vim.notify("Performing default setup...", constants.log_level)
		M.setup()
	end

	local hl_group = next_hl_group()

	-- Go through priorities
	if hllogic.visual_selection(hl_group) ~= nil then
		P("visual selection passed")
	elseif hllogic.treesitter(hl_group) ~= nil then
		P("treesitter approach passed")
	else
		-- Base case
		hllogic.cword_pattern(hl_group)
		P("patttern approach passed")
	end
end
-- TODO: remove
M.highlight_word_under_cursor = M.highlight_at_cursor

--[[
Clear highlights in the module-specific namespace
--]]
M.clear_highlights = function()
	vim.api.nvim_buf_clear_namespace(0, constants.ns_id, 0, -1)
end

--[[
Setup function

  config = {
  hl_groups = {#hex1,#hex2,hlgroup1}
}
TODO: add types config :Config?
--]]
M.setup = function(config)
	-- Reset current config
	utils.remove_hl_groups(custom_hl_groups or {})
	custom_hl_groups = {}
	usable_hl_groups = {}

	-- Load
	config = config or {}

	local hl_groups = config.hl_groups or constants.defaultHLGroups
	if hl_groups == nil or #hl_groups == 0 then
		vim.notify("No hl_groups specified!", vim.log.levels.ERROR)
		return nil
	end

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

	-- Create new hl groups and remember their names
	table.sort(custom_hex_colors)
	custom_hl_groups = utils.create_new_hl_groups(custom_hex_colors)

	-- Concat valid & new hl groups
	table.sort(existing_hl_groups)
	usable_hl_groups = {}
	for _, value in pairs(existing_hl_groups) do
		table.insert(usable_hl_groups, value)
	end
	for _, value in pairs(custom_hl_groups) do
		table.insert(usable_hl_groups, value)
	end

	if usable_hl_groups == nil or #usable_hl_groups == 0 then
		vim.notify("No hl_groups to use!", vim.log.levels.ERROR)
		return nil
	end

	vim.notify("Using the following HL groups: " .. vim.inspect(usable_hl_groups), constants.log_level)
	return M
end

return M
