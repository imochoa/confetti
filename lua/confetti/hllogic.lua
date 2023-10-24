local M = {}

local constants = require("confetti.constants")
local ts_utils = require("nvim-treesitter.ts_utils")

---@class Job More info with 'help: highlight', 'help: highlight-args'
---@field fcn function what to call
---@field args string|nil

-- TODO:use jobs
-- TODO: return nil|Job

--[[
default highlighting logic, should always work
Only works on 1 line!
Using both regexp matching to find lines and literal text in lua...

    vim.fn.search -> search for pattern, return line number. 'n' flag to not move cursor
    vim.fn.getline -> get contents of line
    vim.fn.matchlist -> search for pattern in String, return list of matches, using capture groups

    # EXAMPLE
    local defaults = vim.fn.matchlist(vim.fn.getline(vim.fn.search('^defaults:', 'n')), '^defaults:\\s*\\(.*\\)$')[2]
    defaults = defaults and ' -d '..defaults or ''

    vim.bo.makeprg = 'pandoc' .. defaults .. ' -o "%:p:r.pdf" "%:p"'
    vim.bo.errorformat = '%f, line %l: %m' -- TODO

--]]
---@param regexp string Regular expression for vim.fn.searchpos
---@param hl_group string
---@return boolean ok
local hl_with_pattern_search = function(regexp, hl_group)
	local cursor_pos = vim.api.nvim_win_get_cursor(0) -- remember cursor position
	-- TODO: remember and recover visible screen?

	vim.notify("Pattern: <" .. regexp .. ">", constants.log_level)
	vim.api.nvim_win_set_cursor(0, { 1, 0 })

	local line_txt
	local start, final
	local lnum, col = 1, 0
	-- local dont_wrap = "W"
	-- 'n'	do Not move the cursor
	-- 'W'	don't Wrap around the end of the file
	local search_flags = "W"
	while (lnum > 0) or (col > 0) do
		lnum, col = unpack(vim.fn.searchpos(regexp, search_flags))
		line_txt = vim.fn.getline(lnum)
		final = 0
		while final ~= -1 do
			_, start, final = unpack(vim.fn.matchstrpos(line_txt, regexp, start))
			if start ~= -1 and final ~= -1 then
				-- P("Line, start,final")
				-- P({ lnum, start, final })
				vim.api.nvim_buf_add_highlight(0, constants.ns_id, hl_group, lnum - 1, start, final)
				start = final
			end
		end
		vim.api.nvim_win_set_cursor(0, { lnum + 1, 0 })
	end
	-- Recover cursor position
	vim.api.nvim_win_set_cursor(0, cursor_pos)
	return true
end

--[[
Visual selection
--]]
---@param hl_group string
---@return Job?
M.visual_selection = function(hl_group)
	if vim.api.nvim_get_mode().mode ~= "v" then
		-- Not in visual mode
		return nil
	end
	-- Get visual selection (see https://www.davekuhlman.org/nvim-lua-info-notes.html)
	-- CURRENT visual selection between v .
	-- Last visual selection is between < >
	local _, line1, col1, _ = unpack(vim.fn.getpos("v"))
	local _, line2, col2, _ = unpack(vim.fn.getpos("."))
	-- Looks good actually, but could use cursor_pos?
	-- local end_line, end_col = unpack(P(vim.api.nvim_win_get_cursor(0)))

	-- Do we need to sort?
	if line1 >= line2 and col1 > col2 then
		local auxl, auxc = unpack({ line1, col1 })
		line1, col1 = unpack({ line2, col2 })
		line2, col2 = unpack({ auxl, auxc })
	end
	-- local tt = vim.api.nvim_buf_get_text(0, ls-1, cs-1, le-1, ce, {})
	-- local start_line, start_col = unpack(P(vim.api.nvim_buf_get_mark(0, "<"))) -- no workee
	--
	-- local end_line, end_col = unpack(P(vim.api.nvim_buf_get_mark(0, "'")))
	-- P(end_line)
	-- P(end_col)
	-- Use the line locations to retrieve the text in the selection/range.
	-- The result is a table (array) containing one element for each line

	-- register type "c""v" charwise "l""V"linewise "b"blockwise-visual
	local charwise = "c"
	local region = vim.region(0, { line1, col1 }, { line2, col2 }, charwise, true)
	local text = ""
	for linenr, cols in pairs(region) do
		local buffer_text_tbl = vim.api.nvim_buf_get_text(0, linenr - 1, cols[1] - 1, linenr - 1, cols[2] - 1, {})
		-- Only ever one line, so [1] is fine
		text = text .. buffer_text_tbl[1]
	end
	-- local selected_lines = vim.api.nvim_buf_get_lines(0, line1 - 1, end_line, true)
	-- P(selected_lines)
	-- local selected_text = table.concat(selected_lines, "\n")
	-- P(selected_text)
	-- TODO: trim?
	-- vim.fn.trim(text, mask?, dir?)
	if #text == 0 then
		return nil
	end
	vim.notify("Visual selection: <" .. text .. ">", constants.log_level)
	local regexp = text
	if hl_with_pattern_search(regexp, hl_group) then
		return { fcn = hl_with_pattern_search, args = { regexp, hl_group } }
	end
	return nil
end

--[[
default highlighting logic, should always work
	-- TODO: try builtin.grep_string() Default result is current word
	-- local current_word = require("telescope.builtin").grep_string()
--]]
---@param hl_group string
---@return Job?
M.cword = function(hl_group)
	---@type string
	local current_word = vim.call("expand", "<cword>") ---@diagnostic disable-line: param-type-mismatch,assign-type-mismatch
	vim.notify("Current word: <" .. current_word .. ">", constants.log_level)
	-- local regexp = "\\W\\zs" .. current_word .. "\\ze\\W"
	-- local regexp = "\\s\\zs" .. current_word .. "\\ze\\s"
	-- But it will still miss vi followed by the punctuation or at the end of the line/file. The right way is to put special word boundary symbols "\<" and "\>" around vi.
	-- s:\<vi\>:VIM:g
	local regexp = "\\<" .. current_word .. "\\>"
	vim.notify("regexp: <" .. regexp .. ">", constants.log_level)
	if hl_with_pattern_search(regexp, hl_group) then
		return { fcn = hl_with_pattern_search, args = { regexp, hl_group } }
	end
	return nil
end

--[[
TODO: input?
--]]
---@param hl_group string
---@return boolean ok
local hl_with_treesitter = function(hl_group)
	local language_tree = nil
	local status, _ = pcall(function()
		language_tree = vim.treesitter.get_parser()
	end)

	if status == false then
		return false
	end

	local syntax_tree = language_tree:parse()
	local root = syntax_tree[1]:root()

	local lang = language_tree:lang()
	local curr_node = ts_utils.get_node_at_cursor()
	local node_text = vim.treesitter.get_node_text(curr_node, 0)
	local query_text = string.format('((identifier) @cword (#eq? @cword "%s"))', node_text)
	local query = vim.treesitter.query.parse(lang, query_text)

	local m = false
	for pattern, match, metadata in query:iter_matches(root, 0) do
		-- P("outer")
		-- P({ match = getmetatable(match) })
		for id, node in pairs(match) do
			-- P("inner")
			-- local type = node:type() -- type of the captured node
			local row1, col1, row2, col2 = node:range() -- range of the capture
			vim.api.nvim_buf_add_highlight(0, constants.ns_id, hl_group, row1, col1, col2)
			m = true
		end
	end
	return m
end

--[[
Function to bind
--]]
---@param hl_group string
---@return Job?
M.treesitter = function(hl_group)
	--TODO: incorrect args to call this again
	if hl_with_treesitter(hl_group) then
		return { fcn = hl_with_treesitter, args = { hl_group } }
	end
	return nil
end

return M
