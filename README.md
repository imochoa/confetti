# confetti
Highlight lots of words like it's a party!


# Installation

## Using LazyVim

```lua
-- ~/.config/nvim/lua/plugins/confetti.lua
return {
  {
    "imochoa/confetti",
    -- opts = { },
    keys = {
      {
        "<leader>*",
        function()
          require("confetti").highlight_word_under_cursor()
        end,
        desc = "highlight_word_under_cursor",
      },
      {
        "<leader>**",
        function()
          require("confetti").clear_highlights()
        end,
        desc = "clear it",
      },
    },
  },
}
```
