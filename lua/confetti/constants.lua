local M = {}

M.ns_id = vim.api.nvim_create_namespace("ConfettiHighlights") -- highlight group for this plugin
M.window = 0 -- this window
M.buffer = 0 -- this buffer
M.nvim_global_hl_groups = vim.api.nvim_get_hl(0, {}) -- Known highlight groups
M.log_level = vim.log.levels.DEBUG
-- M.log_level = vim.log.levels.INFO
-- TODO: set default fgcolor to white/black depending on current text color?
M.default_colors = {
	{
		guifg = "black",
		guibg = "white",
		altfont = false,
		bold = false,
		inverse = false, -- Inverse will flip fg and bg ... (not too useful)
		italic = false,
		nocombine = false,
		standout = false,
		strikethrough = false,
		undercurl = false,
		underdashed = false,
		underdotted = false,
		underdouble = false,
		underline = false,
	},
	{ guifg = "black", guibg = "magenta", altfont = true },
	{ guifg = "black", guibg = "lime", bold = true },
	{ guifg = "black", guibg = "yellow", italic = true },
	{ guifg = "black", guibg = "red", nocombine = true },
	{ guifg = "black", guibg = "darkviolet", standout = true },
	{ guifg = "black", guibg = "chocolate", strikethrough = true },
	{ guifg = "black", guibg = "thistle", undercurl = true },
	{ guifg = "black", guibg = "orangered", underdashed = true },
	{ guifg = "black", guibg = "greenyellow", underdotted = true },
	{ guifg = "black", guibg = "acqua", underdouble = true },
	{ guifg = "black", guibg = "hotpink", underline = true },
}

-- 							*tui-colors*
-- Nvim uses 256 colours by default, ignoring |terminfo| for most terminal types,
-- including "linux" (whose virtual terminals have had 256-colour support since
-- 4.8) and anything claiming to be "xterm".  Also when $COLORTERM or $TERM
-- contain the string "256".

-- named colors
-- From the help for 'termguicolors':
--
--     Note that the cterm attributes are still used, not the gui ones.
--
-- Read more:
--
--     :h highlight-args
--     :h cterm-colors

-- https://upload.wikimedia.org/wikipedia/commons/e/e7/SVG1.1_Color_Swatch.svg

return M
