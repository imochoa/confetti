<!--toc:start-->
- [Plugin 'running-man.nvim'](#plugin-running-mannvim)
  - [Structure](#structure)
  - [Loading](#loading)
  - [Testing](#testing)
  - [deps dir](#deps-dir)
  - [tests dir](#tests-dir)
  - [Running](#running)
    - [Interative](#interative)
    - [Headless](#headless)
  - [Debugging](#debugging)
- [References](#references)
<!--toc:end-->

# Plugin 'running-man.nvim'

## Structure

```

running-man.nvim/
├── justfile
├── lua
│   └── running-man
│       └── init.lua
├── plugin
│   └── loadit.lua
├── README.md
├── scripts
│   └── minimal_init.lua
└── tests
```

## Loading

1. Open [./scripts/minimal_init.lua](./scripts/minimal_init.lua)
2. Load it`:luafile %`
    1. it sets the runtimepath (rtp)
    2. loads [./plugin/loadit.lua](./plugin/loadit.lua) which sets a command and keymap to call `M._deveop()`

## Testing

```lua
vim.keymap.set("n", "<space><space>x", "<cmd>source %<CR>")
vim.keymap.set("n", "<space>x", ":.lua<CR>")
vim.keymap.set ("v", "<space>x", ": lua<CR>")
```

## deps dir

```bash
mkdir -p deps
git clone --filter=blob:none https://github.com/nvim-mini/mini.nvim deps/mini.nvim
```

## tests dir

1. Start with `test_....lua`
2. template:

```lua
local new_set = MiniTest.new_set
local expect, eq = MiniTest.expect, MiniTest.expect.equality

local T = new_set()

-- Actual tests definitions will go here

return T
```

## Running

### Interative

To run tests, simply execute :lua MiniTest.run() / :lua MiniTest.run_file() / :lua MiniTest.run_at_location() (assuming, you already have 'mini.test' set up with require('mini.test').setup()). With default configuration this will result into floating window with information about results of test execution. Press q to close it. Note: Be careful though, as it might affect your current setup. To avoid this, use child processes inside tests.

`:luafile scripts/minimal_init.lua`

### Headless

Start headless Neovim process with proper startup file and execute lua MiniTest.run(). Assuming full file organization from previous section, this can be achieved with make test. This will show information about results of test execution directly in shell.

## Debugging

# References

- <https://zignar.net/2023/06/10/debugging-lua-in-neovim/>
- <https://hiphish.github.io/blog/2024/02/20/debugging-lua-scripts-running-in-neovim/>
- <https://github.com/jbyuki/one-small-step-for-vimkind/blob/main/doc/osv.txt>
- <https://github.com/nvim-mini/mini.nvim/blob/main/TESTING.md>
