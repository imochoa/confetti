local M = {}

local constants = require("confetti.constants")

--[[
Visual selection
--]]
---@param hl_group string
---@return nil
M.visual_selection = function(hl_group)
	-- TODO: implement
	return nil
end

--[[
default highlighting logic, should always work
--]]
---@param hl_group string
M.cword_pattern = function(hl_group)
	local current_word = vim.call("expand", "<cword>") ---@diagnostic disable-line: param-type-mismatch
	local pattern = current_word
	-- TODO: try builtin.grep_string() Default result is current word
	-- local current_word = require("telescope.builtin").grep_string()

	local cursor_pos = vim.api.nvim_win_get_cursor(constants.window) -- remember cursor position
	-- TODO: remember and recover visible screen?

	vim.notify("Pattern: <" .. pattern .. ">", constants.log_level)
	vim.api.nvim_win_set_cursor(constants.window, { 1, 0 })

	local line_txt
	local start, final
	local lnum, col = 1, 0
	while (lnum > 0) or (col > 0) do
		lnum, col = unpack(vim.fn.searchpos(pattern .. "\\W", "W")) --, stopline?, timeout?, skip?))

		-- TODO: does vim.fn.searchpos return the multiple matches per line?
		line_txt = vim.fn.getline(lnum)
		final = 0
		while final ~= nil do
			start, final, _ = line_txt:find(pattern, final)
			if start ~= nil and final ~= nil then
				vim.api.nvim_buf_add_highlight(0, constants.ns_id, hl_group, lnum - 1, start - 1, final)
			end
		end
	end
	-- Recover cursor position
	vim.api.nvim_win_set_cursor(constants.window, cursor_pos)
end

--[[
Function to bind
--]]
---@param hl_group string
M.treesitter = function(hl_group)
	-- attempt to get the language tree
	local current_word = vim.call("expand", "<cword>") ---@diagnostic disable-line: param-type-mismatch

	local language_tree = nil
	local status, _ = pcall(function()
		language_tree = vim.treesitter.get_parser()
	end)

	if status == false then
		return nil
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
	-- end
end

return M
