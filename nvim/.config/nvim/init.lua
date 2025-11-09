-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy").setup({
  extras = {
    "lazyvim.plugins.extras.lang.lua",
    "lazyvim.plugins.extras.lang.python",
  },
})
