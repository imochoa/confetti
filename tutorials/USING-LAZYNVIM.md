
# in the setup

1. Add the plugin as usual, as if you were pulling it from github

      ```lua
      -- lua/plugin/your-plugin.lua
      return {
        "<githubName>/<repo.nvim>"
      }
    ```

2. In the lazy setup call, add a `dev` section

      ```lua
      -- lua/config/lazy.lua
      require("lazy").setup({
        spec = { },
        defaults = { },
        install = {  },
        -- ...
        -- Developing my extensions
        dev = {
          -- what plugins to resolve locally
          patterns = { "imochoa" },
          path = function(plugin)
            vim.notify(string.format("DEV mode: loading %s from local path", plugin.name), vim.log.levels.INFO)
            -- where to load it from
            return "~/Code/plugins/" .. plugin.name
          end,
          fallback = true, -- fall back to git if local not found (default)
        },
      })

      ```
