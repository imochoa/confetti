local M = {}

local constants = require("confetti.constants")
local utils = require("confetti.utils")
local hllogic = require("confetti.hllogic")

--[[
Private cache
--]]
local new_hlgroups = {}
local usable_hl_groups = {}
local current_hl_group_idx = 1
local _fwd_config = {} -- For debugging

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
	require("confetti").setup(_fwd_config)
	-- TODO: need to store more cache: current idx, usable hl_groups, new_hlgroups
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
	vim.notify("Using: " .. hl_group, constants.log_level)

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

--[[
Clear highlights in the module-specific namespace
--]]
M.clear_highlights = function()
	vim.api.nvim_buf_clear_namespace(0, constants.ns_id, 0, -1)
end

---@class ConfettiConfig
---@field reused_hlgroups string[] List of existing highlight groups to use
---@field colors GuiHighlight[] New highlights to create with a lua interface

--[[
Setup function

  config = {
  hl_groups = {#hex1,#hex2,hlgroup1}
}
TODO: add types config :Config?
--]]
M.setup = function(config)
	-- Reset
	_fwd_config = config
	utils.remove_hl_groups(new_hlgroups or {})
	new_hlgroups = {}

	-- handle nil
	config = config == nil and {} or config
	config.reused_hlgroups = config.reused_hlgroups == nil and {} or config.reused_hlgroups
	config.colors = config.colors == nil and {} or config.colors
	-- handle empty
	config.colors = #config.colors == 0 and constants.default_colors or config.colors

	-- Existing groups?
	local reused_hlgroups = {}
	for _, el in ipairs(config.reused_hlgroups) do
		if constants.nvim_global_hl_groups[el] ~= nil then
			-- Was an existing highlight group
			table.insert(reused_hlgroups, el)
		end
	end
	table.sort(reused_hlgroups)

	-- New groups?
	new_hlgroups = utils.create_hl_groups(config.colors)

	-- Concat valid & new hl groups
	usable_hl_groups = reused_hlgroups
	for _, v in pairs(new_hlgroups) do
		table.insert(usable_hl_groups, v)
	end

	if #usable_hl_groups == 0 then
		vim.notify("No hl_groups to use!", vim.log.levels.ERROR)
		return nil
	end

	vim.notify("Using the following HL groups: " .. vim.inspect(usable_hl_groups), constants.log_level)
	return M
end

return M
