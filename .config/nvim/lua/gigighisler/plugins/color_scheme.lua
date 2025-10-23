return {
	"navarasu/onedark.nvim",
	priority = 1000, -- Ensure it loads first
	config = function()
		require("onedark").setup({
			style = "dark", -- or 'cool', 'deep', etc.
			transparent = true, -- enable transparency
		})
		vim.cmd("colorscheme onedark")

		-- Add your custom highlight
		vim.api.nvim_set_hl(0, "DatabricksCommand", {
			fg = "#e06c75", -- OneDark red/pink accent
			bg = "#ffffff", -- slightly lighter than main background
			bold = true,
		})

		-- Add the matching autocmd
		vim.api.nvim_create_augroup("DatabricksHighlight", { clear = true })
		vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile", "BufEnter" }, {
			pattern = "*.py",
			group = "DatabricksHighlight",
			callback = function()
				vim.fn.matchadd("DatabricksCommand", "^# COMMAND ----------.*$")
        vim.fn.matchadd("DatabricksCommand", "^# Databricks notebook source.*$")
			end,
		})
	end,
}
