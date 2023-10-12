local M = {}

M.ns_id = vim.api.nvim_create_namespace("ConfettiHighlights") -- highlight group for this plugin
M.window = 0 -- this window
M.buffer = 0 -- this buffer
M.nvim_global_hl_groups = vim.api.nvim_get_hl(0, {}) -- Known highlight groups
-- M.log_level = vim.log.levels.DEBUG
M.log_level = vim.log.levels.INFO
M.defaultHLGroups = {
	"#cc241d",
	"#a89984",
	"#b16286",
	"#d79921",
	"#689d6a",
	"#d65d0e",
	"#458588",
}

return M
