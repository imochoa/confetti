local M = {}

local constants = require("confetti.constants")

---@class Job More info with 'help: highlight', 'help: highlight-args'
---@field fcn function what to call
---@field args string|nil

---@type Job[]
local jobs = {} -- Keep track of what has been highlighted

-- TODO:use jobs
-- TODO: return nil|Job

--[[
default highlighting logic, should always work
Only works on 1 line!
Using both regexp matching to find lines and literal text in lua...
--]]
---@param regexp string Regular expression for vim.fn.searchpos
---@param text string Literal text that we're trying to detect in the buffer
---@param hl_group string
---@return boolean ok it work?
local highlight_pattern = function(regexp, text, hl_group)
	local cursor_pos = vim.api.nvim_win_get_cursor(constants.window) -- remember cursor position
	-- TODO: remember and recover visible screen?

	vim.notify("Pattern: <" .. regexp .. ">", constants.log_level)
	vim.api.nvim_win_set_cursor(constants.window, { 1, 0 })

	local line_txt
	local start, final
	local lnum, col = 1, 0
	local dont_wrap = "W"
	while (lnum > 0) or (col > 0) do
		lnum, col = unpack(vim.fn.searchpos(regexp, dont_wrap)) --, stopline?, timeout?, skip?))
		line_txt = vim.fn.getline(lnum)
		final = 0
		while final ~= nil do
			start, final, _ = line_txt:find(text, final)
			if start ~= nil and final ~= nil then
				-- https://fossies.org/linux/neovim/runtime/lua/vim/highlight.lua
				vim.api.nvim_buf_add_highlight(0, constants.ns_id, hl_group, lnum - 1, start - 1, final)
			end
		end
	end
	-- Recover cursor position
	vim.api.nvim_win_set_cursor(constants.window, cursor_pos)
	return true
end

--[[
Visual selection
--]]
---@param hl_group string
---@return boolean
M.visual_selection = function(hl_group)
	if vim.api.nvim_get_mode().mode ~= "v" then
		-- Not in visual mode
		return false
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
		return false
	end
	P("Visual selection: <" .. text .. ">")
	local regexp = text
	return highlight_pattern(regexp, text, hl_group)
end

--[[
default highlighting logic, should always work
	-- TODO: try builtin.grep_string() Default result is current word
	-- local current_word = require("telescope.builtin").grep_string()
--]]
---@param hl_group string
---@return boolean
M.cword_pattern = function(hl_group)
	---@type current_word string
	local current_word = vim.call("expand", "<cword>") ---@diagnostic disable-line: param-type-mismatch,assign-type-mismatch
	P("Current word: <" .. current_word .. ">")
	local regexp = current_word .. ""
	P("regexp: <" .. regexp .. ">")
	return highlight_pattern(regexp, current_word, hl_group)
end

--[[
Function to bind
--]]
---@param hl_group string
---@return boolean
M.treesitter = function(hl_group)
	-- attempt to get the language tree
	local current_word = vim.call("expand", "<cword>") ---@diagnostic disable-line: param-type-mismatch

	local language_tree = nil
	local status, _ = pcall(function()
		language_tree = vim.treesitter.get_parser()
	end)

	if status == false then
		return false
	end

	-- TODO: use treesitter symbols instead of searching?
	-- vim.show_pos() -- Similar to :Inspect (prints text)
	-- local pos = vim.inspect_pos()
	--
	-- local pos_ts = pos.treesitter or {}
	-- if #pos.treesitter > 1 then
	-- 	P("treesitter")
	-- 	pos_ts = pos.treesitter[1]
	-- 	P(getmetatable(pos_ts))
	-- end
	-- if #pos.semantic_tokens > 1 then
	-- 	P("semantic tokens")
	-- 	pos_st = pos.semantic_tokens[1]
	-- 	P(pos_st)
	-- end
	--TODO:
	-- :Inspect to show the highlight groups under the cursor
	-- :InspectTree to show the parsed syntax tree ("TSPlayground")
	-- :EditQuery to open the Live Query Editor (Nvim 0.10+)
	--
	-- local status, err = pcall(function () error({code=121}) end)
	-- local ts_node_at_cursor = require("nvim-treesitter.ts_utils").get_node_at_cursor()
	-- getmetatable(ts_node_at_cursor)
	-- P("ts_node_at_cursor")
	-- P(getmetatable(ts_node_at_cursor))
	-- P("id")
	-- P(ts_node_at_cursor.id)
	-- local status, err = pcall(function () error({code=121}) end)
	-- Attempt to get the treesitter parser

	-- 	local syntax_tree = language_tree:parse()
	-- 	local root = syntax_tree[1]:root()
	--
	-- local filetype = vim.api.nvim_buf_get_option(buffer, "filetype")
	-- local lang = require("nvim-treesitter.parsers").ft_to_lang(filetype)
	-- --
	-- -- local parser = vim.treesitter.get_parser(nil, nil, nil)
	-- local query_text = [[
	-- ((identifier) @variable.builtin
	--   (#eq? @variable.builtin "]] .. current_word .. [["))
	--   ]]
	-- local query = vim.treesitter.query.parse(lang, query_text)
	-- -- for-loop pattern
	-- for id, capture, metadata in query:iter_captures(root, buffer) do
	-- 	-- local name = query.captures[id] -- name of the capture in the query
	-- 	-- typically useful info about the node:
	-- 	-- local type = node:type() -- type of the captured node
	-- 	-- local row1, col1, row2, col2 = node:range() -- range of the capture
	-- 	P("loop!")
	-- 	-- 	-- ... use the info here ...
	-- end
	-- P("parser")
	--  parser
	-- P(parser)
	-- local query = vim.treesitter.query.add_directive(name, handler, force)
	-- local handler = function(match, pattern,bufnr, predicate, metadata)
	-- local query = vim.treesitter.query.add_predicate("eq?", function (match, pattern)
	--
	-- end
	-- predicate to match
	-- ((identifier) @variable.builtin (#eq? @variable.builtin "variable_name"))
	-- local query = vim.treesitter.parse_query( 'java', '(method_declaration)')

	-- for id, match, metadata in query:iter_matches(root, <bufnr>, root:start(), root:end_()) do
	--     print(vim.inspect(getmetatable(match[1])))
	-- end return false
end

return M
