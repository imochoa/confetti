<https://github.com/nvim-mini/mini.nvim/blob/main/TESTING.md>

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

MiniTest.run_file(): This function is designed to run all test cases within a specified Lua file. It's useful when you want to execute a comprehensive suite of tests for a particular module or feature.
1
2

MiniTest.run_at_location(): This function allows you to run a test case located at a specific position, typically the current cursor position within your Neovim editor. This is convenient for quickly testing a single test case or a small section of code without running the entire file.
1

`:luafile scripts/minimal_init.lua`

### Headless

Start headless Neovim process with proper startup file and execute lua MiniTest.run(). Assuming full file organization from previous section, this can be achieved with make test. This will show information about results of test execution directly in shell.
