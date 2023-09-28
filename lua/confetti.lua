local M = {}

--[[ rPrint(struct, [limit], [indent])   Recursively print arbitrary data. 
	Set limit (default 100) to stanch infinite loops.
	Indents tables as [KEY] VALUE, nested tables as [KEY] [KEY]...[KEY] VALUE
	Set indent ("") to prefix each line:    Mytable [KEY] [KEY]...[KEY] VALUE
--]]
M._rPrint = function(s, l, i) -- recursive Print (structure, limit, indent)
	l = l or 100
	i = i or "" -- default item limit, indent string
	if l < 1 then
		print("ERROR: Item limit reached.")
		return l - 1
	end
	local ts = type(s)
	if ts ~= "table" then
		print(i, ts, s)
		return l - 1
	end
	print(i, ts) -- print "table"
	for k, v in pairs(s) do -- print "[KEY] VALUE"
		l = M._rPrint(v, l, i .. "\t[" .. tostring(k) .. "]")
		if l < 0 then
			break
		end
	end
	return l
end

M.globals =
	{ ns_id = vim.api.nvim_create_namespace("RainbowHighlights"), filtered_hl_groups = {}, next_filtered_hl_index = 1 }

M._set_hl_groups_with_filter = function()
	local global_hl_groups = vim.api.nvim_get_hl(0, {})
	local filtered_hl_groups = {}
	for k, v in pairs(global_hl_groups) do
		-- if v["fg"] and v["bg"] then
		-- if v["guifg"] and v["guibg"] then -- NO MATCHES!
		-- if v["ctermfg"] and v["ctermbg"] then -- just 2 matches?
		if v["ctermbg"] then -- 5 matches
			table.insert(filtered_hl_groups, k)
		end
	end

	if #filtered_hl_groups == 0 then
		vim.notify("Nothing to highlight under cursor!", vim.log.levels.ERROR)
	else
		vim.notify("Found " .. #filtered_hl_groups .. " groups", vim.log.levels.TRACE)
	end
	table.sort(filtered_hl_groups)
	M.globals.filtered_hl_groups = filtered_hl_groups
end

M._set_manual_hl_groups = function(bgcolors)
	local filtered_hl_groups = {}

	for i, v in ipairs(bgcolors) do
		local hl_group_name = "HHLLG" .. i
		local cmd_str = "highlight " .. hl_group_name .. " guibg=" .. v
		-- guibg?
		-- vim.notify(cmd_str)
		vim.cmd(cmd_str)
		table.insert(filtered_hl_groups, hl_group_name)
	end

	-- vim.notify(#filtered_hl_groups)
	table.sort(filtered_hl_groups)
	M.globals.filtered_hl_groups = filtered_hl_groups
end

M._highlight_pattern = function(pattern, hl_group)
	local ns_id = M.globals.ns_id
	-- vim.api.nvim_buf_get_text(buffer, start_row, start_col, end_row, end_col, opts)
	local text_table = vim.api.nvim_buf_get_lines(0, 0, -1, false)

	for line_no, line_txt in ipairs(text_table) do
		local start, final
		final = 0
		while final ~= nil do
			start, final, _ = line_txt:find(pattern, final)
			if start ~= nil and final ~= nil then
				vim.api.nvim_buf_add_highlight(0, ns_id, hl_group, line_no - 1, start - 1, final)
			end
		end
	end
end

M.highlight_word_under_cursor = function()
	-- is there a more "lua" way of doing this?
	local current_word = vim.call("expand", "<cword>")
	-- M._rPrint(current_word)

	--TODO check if already has a hl group and remove it?
	local hl_group = M.globals.filtered_hl_groups[M.globals.next_filtered_hl_index]
	-- vim.notify(hl_group)

	M.globals.next_filtered_hl_index = M.globals.next_filtered_hl_index % #M.globals.filtered_hl_groups + 1
	-- M._rPrint(#filtered_hl_groups)
	-- M._rPrint(hl_group)
	-- -- local hl_group = filtered_hl_groups[1] -- 1 indexed!
	M._highlight_pattern(current_word, hl_group)
end

M.clear_highlights = function()
	vim.api.nvim_buf_clear_namespace(0, M.globals.ns_id, 0, -1)
end

-- Must run once
-- M._set_hl_groups_with_filter()
M._set_manual_hl_groups({
	"#cc241d",
	"#a89984",
	"#b16286",
	"#d79921",
	"#689d6a",
	"#d65d0e",
	"#458588",
})

local _config = {}
M.setup = function(config)
	_config = config
end

return M
