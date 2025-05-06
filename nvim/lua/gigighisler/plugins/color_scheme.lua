return{
  'navarasu/onedark.nvim',
  priority = 1000, -- Ensure it loads first
  config = function()
    require('onedark').setup {
      style = 'dark', -- or 'cool', 'deep', etc.
      transparent = true, -- enable transparency
    }
    vim.cmd("colorscheme onedark")
  end
}
