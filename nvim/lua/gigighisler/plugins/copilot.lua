return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    event = "BufReadPost",
    opts = function()
      -- Define your own namespace for cmp actions if needed
      _G.cmp_actions = _G.cmp_actions or {}

      -- ai_accept function, replacing LazyVim.create_undo with vim.cmd("undojoin")
      _G.cmp_actions.ai_accept = function()
        local suggestion = require("copilot.suggestion")
        if suggestion.is_visible() then
          vim.cmd("undojoin")
          suggestion.accept()
          return true
        end
      end

      return {
        suggestion = {
          enabled = not vim.g.ai_cmp,
          auto_trigger = true,
          hide_during_completion = vim.g.ai_cmp,
          keymap = {
            accept = "<Tab>",
            next = "<M-]>",
            prev = "<M-[>",
          },
        },
        panel = { enabled = false },
        filetypes = {
          markdown = true,
          help = true,
        },
      }
    end,
  },

}
