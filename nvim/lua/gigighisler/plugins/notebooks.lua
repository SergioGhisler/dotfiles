return {
	{
		"benlubas/molten-nvim",
		dependencies = { "3rd/image.nvim" },
		build = ":UpdateRemotePlugins",
		init = function()
			vim.g.molten_auto_open_output = false
			vim.g.molten_image_provider = "image.nvim"
			vim.g.molten_wrap_output = true
			-- vim.g.molten_virt_text_output = true -- show output as virtual text  [oai_citation_attribution:3‡GitHub](https://github.com/benlubas/molten-nvim/blob/main/docs/Notebook-Setup.md)
			vim.g.molten_virt_lines_off_by_1 = true -- align virt text under the cell  [oai_citation_attribution:4‡GitHub](https://github.com/benlubas/molten-nvim/blob/main/docs/Notebook-Setup.md)
			vim.g.molten_output_win_max_height = 20
			vim.g.molten_tick_rate = 200
		end,
		config = function()
			local map = vim.keymap.set
			-- keymaps for running cells & interacting with molten  [oai_citation_attribution:5‡GitHub](https://github.com/benlubas/molten-nvim/blob/main/docs/Notebook-Setup.md)
			map("n", "<leader>mi", ":MoltenInit<CR>", { desc = "init Molten kernel", silent = true })
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "quarto", "markdown", "ipynb" },
				callback = function()
					map("n", "<C-n>", ":MoltenNext<CR>", { desc = "next cell", buffer = true, silent = true })
					map("n", "<C-p>", ":MoltenPrev<CR>", { desc = "prev cell", buffer = true, silent = true })
				end,
			})
			map("n", "<leader>e", ":MoltenEvaluateOperator<CR>", { desc = "evaluate operator", silent = true })
			map("n", "<leader>os", ":noautocmd MoltenEnterOutput<CR>", { desc = "open output window", silent = true })
			map("n", "<leader>rr", ":MoltenReevaluateCell<CR>", { desc = "re‑eval cell", silent = true })
			map(
				"v",
				"<leader>r",
				":<C‑u>MoltenEvaluateVisual<CR>gv",
				{ desc = "execute visual selection", silent = true }
			)
			map("n", "<leader>oh", ":MoltenHideOutput<CR>", { desc = "close output window", silent = true })
			map("n", "<leader>md", ":MoltenDelete<CR>", { desc = "delete Molten cell", silent = true })
			-- if you work with HTML outputs:
			map("n", "<leader>mx", ":MoltenOpenInBrowser<CR>", { desc = "open output in browser", silent = true })

			-- auto‑import/export of notebook outputs  [oai_citation_attribution:6‡GitHub](https://github.com/benlubas/molten-nvim/blob/main/docs/Notebook-Setup.md)
			local function imb(e)
				vim.schedule(function()
					local kernels = vim.fn.MoltenAvailableKernels()
					local ok, meta = pcall(function()
						return vim.json.decode(io.open(e.file, "r"):read("a"))["metadata"]
					end)
					local kn = ok and meta.kernelspec and meta.kernelspec.name or nil
					if not kn or not vim.tbl_contains(kernels, kn) then
						local venv = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
						if venv then
							kn = venv:match("/.+/(.+)")
						end
					end
					if kn and vim.tbl_contains(kernels, kn) then
						vim.cmd(("MoltenInit %s"):format(kn))
					end
					vim.cmd("MoltenImportOutput")
				end)
			end
			vim.api.nvim_create_autocmd({ "BufAdd" }, {
				pattern = { "*.ipynb" },
				callback = imb,
			})
			vim.api.nvim_create_autocmd("BufEnter", {
				pattern = { "*.ipynb" },
				callback = function(e)
					if vim.api.nvim_get_vvar("vim_did_enter") ~= 1 then
						imb(e)
					end
				end,
			})
			vim.api.nvim_create_autocmd("BufWritePost", {
				pattern = { "*.ipynb" },
				callback = function()
					if require("molten.status").initialized() == "Molten" then
						vim.cmd("MoltenExportOutput!")
					end
				end,
			})
			-- Provide a command to create a blank new Python notebook
			-- note: the metadata is needed for Jupytext to understand how to parse the notebook.
			-- if you use another language than Python, you should change it in the template.
			local default_notebook = [[
  {
    "cells": [
     {
      "cell_type": "markdown",
      "metadata": {},
      "source": [
        ""
      ]
     }
    ],
    "metadata": {
     "kernelspec": {
      "display_name": "Python 3",
      "language": "python",
      "name": "python3"
     },
     "language_info": {
      "codemirror_mode": {
        "name": "ipython"
      },
      "file_extension": ".py",
      "mimetype": "text/x-python",
      "name": "python",
      "nbconvert_exporter": "python",
      "pygments_lexer": "ipython3"
     }
    },
    "nbformat": 4,
    "nbformat_minor": 5
  }
]]

			local function new_notebook(filename)
				local path = filename .. ".ipynb"
				local file = io.open(path, "w")
				if file then
					file:write(default_notebook)
					file:close()
					vim.cmd("edit " .. path)
				else
					print("Error: Could not open new notebook file for writing.")
				end
			end

			vim.api.nvim_create_user_command("NewNotebook", function(opts)
				new_notebook(opts.args)
			end, {
				nargs = 1,
				complete = "file",
			})
		end,
	},

	-- quarto‑nvim + otter.nvim for LSP & notebook‑like editing  [oai_citation_attribution:7‡GitHub](https://github.com/benlubas/molten-nvim/blob/main/docs/Notebook-Setup.md) [oai_citation_attribution:8‡GitHub](https://github.com/benlubas/molten-nvim/blob/main/docs/Notebook-Setup.md)
	{
		"quarto-dev/quarto-nvim",
		ft = { "quarto", "markdown" },
		dependencies = {
			"jmbuhr/otter.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("quarto").setup({
				lspFeatures = {
					languages = { "r", "python", "rust" },
					chunks = "all",
					diagnostics = {
						enabled = true,
						triggers = { "BufWritePost" },
					},
					completion = { enabled = true },
				},
				keymap = {
					hover = "H",
					definition = "gd",
					rename = "<leader>rn",
					references = "gr",
					format = "<leader>xf",
				},
				codeRunner = {
					enabled = true,
					default_method = "molten",
				},
			})
			-- activate quarto in markdown buffers  [oai_citation_attribution:9‡GitHub](https://github.com/benlubas/molten-nvim/blob/main/docs/Notebook-Setup.md)
			require("quarto").activate()
			-- quarto runner keymaps  [oai_citation_attribution:10‡GitHub](https://github.com/benlubas/molten-nvim/blob/main/docs/Notebook-Setup.md)
			local runner = require("quarto.runner")
			vim.keymap.set("n", "<leader>rc", runner.run_cell, { desc = "run cell", silent = true })
			vim.keymap.set("n", "<leader>ra", runner.run_above, { desc = "run cell and above", silent = true })
			vim.keymap.set("n", "<leader>rA", runner.run_all, { desc = "run all cells", silent = true })
			vim.keymap.set("n", "<leader>rl", runner.run_line, { desc = "run line", silent = true })
			vim.keymap.set("v", "<leader>r", runner.run_range, { desc = "run visual range", silent = true })
			vim.keymap.set("n", "<leader>RA", function()
				runner.run_all(true)
			end, { desc = "run all languages", silent = true })
		end,
	},

	-- jupytext.nvim for ipynb ↔ markdown conversion  [oai_citation_attribution:11‡GitHub](https://github.com/benlubas/molten-nvim/blob/main/docs/Notebook-Setup.md)

	{ -- directly open ipynb files as quarto docuements
		-- and convert back behind the scenes
		"GCBallesteros/jupytext.nvim",
		opts = {
			custom_language_formatting = {
				python = {
					style = "markdown",
					extension = "md",
					force_ft = "markdown",
					-- extension = "qmd",
					-- style = "quarto",
					-- force_ft = "quarto",
				},
				r = {
					extension = "qmd",
					style = "quarto",
					force_ft = "quarto",
				},
			},
		},
	},
}
