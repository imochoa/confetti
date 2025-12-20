-- vim: ft=lua tw=80

-- Ignore W211 (unused variable) for variables starting with an underscore
self = false

-- Rerun tests only if their modification time changed
cache = true

-- Global objects defined by Neovim
read_globals = {
	"vim",
}

globals = {
	"describe",
	"it",
	"before_each",
	"after_each",
	"setup",
	"teardown",
	"pending",
}

-- Don't report unused self arguments of methods
ignore = {
	"212", -- Unused argument
	"631", -- max_line_length
}

exclude_files = {
	".luarocks",
	".install",
}
