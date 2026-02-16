-- return{
--   "SergioGhisler/databricks-nvim",
--   config = function()
--     require("databricks").setup({
--       -- Option A: regular python
--       -- python = "python3",
--
--       -- Option B (recommended): uv-powered runtime
--       python = "uv", -- enables `uv run`
--       uv = {
--         enabled = true,
--         with = { "databricks-sdk" },
--       },
--
--       bridge_script = vim.fn.stdpath("data") .. "/lazy/databricks-nvim/python/dbx_bridge.py",
--       ui = {
--         border = "rounded",
--         width = 0.7,
--         height = 0.6,
--       },
--     })
--   end,
-- }
return {
  dir = "/Users/sergioghislergomez/Documents/projects/databricks-nvim", -- your local clone path
  name = "databricks-nvim",
  config = function()
    require("databricks").setup({
      python = "uv",
      uv = { enabled = true, with = { "databricks-sdk" } },
      bridge_script = vim.fn.expand("/Users/sergioghislergomez/Documents/projects/databricks-nvim/python/dbx_bridge.py"),
    })
  end,
}
