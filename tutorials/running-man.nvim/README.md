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

## Testing with mini-test

### Setup

```bash
mkdir -p deps
git clone --filter=blob:none https://github.com/nvim-mini/mini.nvim deps/mini.nvim
```

Test structure:

1. Start with `test_<NAME>.lua`
2. template:

    ```lua
    local new_set = MiniTest.new_set
    local expect, eq = MiniTest.expect, MiniTest.expect.equality

    local T = new_set()

    -- Actual tests definitions will go here

    return T
    ```

### Running tests

#### Interative Testing

1. `:lua require('mini.test').setup())`
2. Run it:
    - `:lua MiniTest.run()`
    - `:lua MiniTest.run_file()`
    - `:lua MiniTest.run_at_location()`

> Press q to close it. Note: Be careful though, as it might affect your current setup. To avoid this, use child processes inside tests.

#### Headless Testing

1. `just`
Start headless Neovim process with proper startup file and execute lua MiniTest.run().

## Debugging

# References

- <https://zignar.net/2023/06/10/debugging-lua-in-neovim/>
- <https://hiphish.github.io/blog/2024/02/20/debugging-lua-scripts-running-in-neovim/>
- <https://github.com/jbyuki/one-small-step-for-vimkind/blob/main/doc/osv.txt>
- <https://github.com/nvim-mini/mini.nvim/blob/main/TESTING.md>

# Simplifications

## Loading using LazyVim

Replaces the need for:

- cloning mini.test `(1)`
- `./scripts/minimal_init.lua` for editing rtp (2)
- `./plugin/loadit.lua` (3)

```lua
-- .lazy.lua
-- https://github.com/folke/lazydev.nvim
return {
  -- For mini tests! (1)
 { "nvim-mini/mini.nvim", version = "*" },
  -- For this plugin (2)
 { dir = "/abs/path/to/this/plugin.nvim",
    config = function()
    -- (3)
    vim.api.nvim_create_user_command("ReloadRunningMan", function()
      package.loaded["running-man"] = nil
      local running_man = require("running-man")
      running_man.setup({})
      running_man._develop()
    end, {})

    vim.keymap.set("n", "<space><space><space>", "<cmd>ReloadRunningMan<CR>", { desc = "Reload Running Man plugin" })

    end,
  },
}
```

> **Headless init is still required!**
