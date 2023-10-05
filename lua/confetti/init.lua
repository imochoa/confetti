local M = {}

--[[
Private CONSTANTS
--]]
local ns_id = vim.api.nvim_create_namespace("ConfettiHighlights") -- highlight group for this plugin
local window = 0 -- this window
local nvim_global_hl_groups = vim.api.nvim_get_hl(0, {}) -- Known highlight groups
-- local log_level = vim.log.levels.INFO
local log_level = vim.log.levels.DEBUG
local defaultHLGroups = {
	"#cc241d",
	"#a89984",
	"#b16286",
	"#d79921",
	"#689d6a",
	"#d65d0e",
	"#458588",
}
-- local error_msg = "Found (" .. #nvim_global_hl_groups .. ") global hl groups: " .. vim.inspect(nvim_global_hl_groups)

--[[
Private cache
--]]
local custom_hl_groups = {}
local usable_hl_groups = {}
local current_hl_group_idx = 1

--[[
Reload this module (for debugging)
--]]
M.reload = function()
	require("plenary.reload").reload_module("confetti")
	vim.notify("Reloaded Confetti")
end

--[[

--]]
M._highlight_pattern = function(pattern, hl_group)
	local cursor_pos = vim.api.nvim_win_get_cursor(window) -- remember cursor position
	-- TODO: remember and recover visible screen?

	vim.notify("Pattern: <" .. pattern .. ">", log_level)
	vim.api.nvim_win_set_cursor(window, { 1, 0 })

	local line_txt
	local start, final
	local lnum, col = 1, 0
	while (lnum > 0) or (col > 0) do
		lnum, col = unpack(vim.fn.searchpos(pattern, "W")) --, stopline?, timeout?, skip?))

		-- TODO: does vim.fn.searchpos return the multiple matches per line?
		line_txt = vim.fn.getline(lnum)
		final = 0
		while final ~= nil do
			start, final, _ = line_txt:find(pattern, final)
			if start ~= nil and final ~= nil then
				vim.api.nvim_buf_add_highlight(0, ns_id, hl_group, lnum - 1, start - 1, final)
			end
		end
	end
	vim.api.nvim_win_set_cursor(window, cursor_pos)
end

M.info = function()
	P({
		usable_hl_groups = usable_hl_groups,
		current_hl_group_idx = current_hl_group_idx,
		custom_hl_groups = custom_hl_groups,
	})
end

--[[
Function to bind
--]]
M.highlight_word_under_cursor = function()
	if #(usable_hl_groups or {}) == 0 then
		-- setup has not been called!
		vim.notify("Performing default setup...", log_level)
		M.setup()
		-- vim.notify("No hl groups to highlight!", vim.log.levels.ERROR)
		-- return nil
	end

	-- TODO: use visual selection?
	-- TODO: use treesitter symbols instead of searching?
	-- vim.show_pos() -- Similar to :Inspect (prints text)
	local pos = vim.inspect_pos()
	P(pos)
	local pos_ts = pos.treesitter or {}
	pos_ts = pos.treesitter[1]
	P("treesitter")
	P(pos_ts)
	P("semantic tokens")
	pos_st = pos.semantic_tokens[1]
	P(pos_st)
	--TODO:
	-- :Inspect to show the highlight groups under the cursor
	-- :InspectTree to show the parsed syntax tree ("TSPlayground")
	-- :EditQuery to open the Live Query Editor (Nvim 0.10+)

	local ts_node_at_cursor = require("nvim-treesitter.ts_utils").get_node_at_cursor()
	P(ts_node_at_cursor)
	if pos_ts.capture == "variable" then
		-- vim.treesitter.query.
	end

	local current_word = vim.call("expand", "<cword>")
	-- TODO: try builtin.grep_string() Default result is current word
	-- local current_word = require("telescope.builtin").grep_string()

	local hl_group = usable_hl_groups[current_hl_group_idx]
	-- vim.notify("group: " .. tostring(hl_group))
	-- P("current word: " .. current_word)
	-- P("group: " .. tostring(hl_group))
	-- P(hl_group)
	-- P(hl_group)
	-- M.globals.filtered_hl_groups[M.globals.next_filtered_hl_index]

	-- M.globals.next_filtered_hl_index = M.globals.next_filtered_hl_index % #M.globals.filtered_hl_groups + 1
	current_hl_group_idx = current_hl_group_idx % #usable_hl_groups + 1
	-- P(#filtered_hl_groups)
	-- P(hl_group)
	-- -- local hl_group = filtered_hl_groups[1] -- 1 indexed!
	M._highlight_pattern(current_word, hl_group)
end

--[[
Clear highlights in the module-specific namespace
--]]
M.clear_highlights = function()
	vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
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

--[[
Given an array of *bgcolors* with hex color values e.g. {"#cc241d", "#a89984", "#b16286"}, create new highlight groups for them and return them
--]]
M._create_new_hl_groups = function(bgcolors)
	local new_hl_groups = {}

	for i, v in pairs(bgcolors) do
		local hl_group_name = "ConfettiHLGroup" .. i
		local cmd_str = "highlight " .. hl_group_name .. " guibg=" .. v .. " gui=underline,bold"
		-- guibg?
		vim.cmd(cmd_str)
		vim.notify(cmd_str, log_level)
		table.insert(new_hl_groups, hl_group_name)
	end

	return new_hl_groups
end

--[[
Given a set of *hl_groups*, delete them
--]]
M._remove_hl_groups = function(hl_groups)
	for _, hl_group in ipairs(hl_groups) do
		local cmd_str = "highlight clear " .. hl_group
		vim.cmd(cmd_str)
	end
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
	M._remove_hl_groups(custom_hl_groups or {})
	custom_hl_groups = {}
	usable_hl_groups = {}

	-- Load
	config = config or {}

	local hl_groups = config.hl_groups or defaultHLGroups
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
		elseif nvim_global_hl_groups[el] ~= nil then
			-- Was an existing highlight group
			table.insert(existing_hl_groups, el)
		else
			vim.notify("Ignoring unknown color/highlight group: <" .. el .. ">", vim.log.levels.ERROR)
		end
	end

	-- Create new hl groups and remember their names
	table.sort(custom_hex_colors)
	custom_hl_groups = M._create_new_hl_groups(custom_hex_colors)

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

	vim.notify("Using the following HL groups: " .. vim.inspect(usable_hl_groups), log_level)
	return M
end

return M
