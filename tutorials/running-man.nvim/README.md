
# Structure

```

```

LOading

```lua
vim.opt.rtp:append(vim.fn.stdpath "config" .. "/lua/custom/after")
```

```lua
vim.keymap.set("n", "<space><space>x", "<cmd>source %<CR>")
vim.keymap.set("n", "<space>x", ":.lua<CR>")
vim.keymap.set ("v", "<space>x", ": lua<CR>")
```

# References

- <https://zignar.net/2023/06/10/debugging-lua-in-neovim/>
- <https://hiphish.github.io/blog/2024/02/20/debugging-lua-scripts-running-in-neovim/>
- <https://github.com/jbyuki/one-small-step-for-vimkind/blob/main/doc/osv.txt>
