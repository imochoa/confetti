local M = {}

M.ns_id = vim.api.nvim_create_namespace("ConfettiHighlights") -- highlight group for this plugin
M.window = 0 -- this window
M.buffer = 0 -- this buffer
M.nvim_global_hl_groups = vim.api.nvim_get_hl(0, {}) -- Known highlight groups
M.log_level = vim.log.levels.DEBUG
-- M.log_level = vim.log.levels.INFO
M.default_colors = {
	{
		guifg = "white",
		guibg = "black",
		altfont = true,
		bold = true,
		inverse = true,
		italic = true,
		nocombine = true,
		standout = true,
		strikethrough = true,
		undercurl = true,
		underdashed = true,
		underdotted = true,
		underdouble = true,
		underline = true,
	},
	{
		guifg = "black",
		guibg = "red",
	},
}

return M
