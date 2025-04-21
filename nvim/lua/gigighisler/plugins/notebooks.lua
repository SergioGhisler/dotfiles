return {

	{ -- requires plugins in lua/plugins/treesitter.lua and lua/plugins/lsp.lua
		-- for complete functionality (language features)
		"quarto-dev/quarto-nvim",
		dev = false,
		opts = {
			lspFeatures = {
				enabled = true,
				chunks = "curly",
			},
			codeRunner = {
				enabled = true,
				default_method = "slime",
			},
		},
		config = function(_, opts)
			require("quarto").setup(opts)
			-- Add runner keymaps
			local runner = require("quarto.runner")
			local function insert_new_cell()
				local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
				local cell_lines = {
					"```{python}",
					"",
					"```",
				}
				vim.api.nvim_buf_set_lines(0, row, row, false, cell_lines)
				vim.api.nvim_win_set_cursor(0, { row + 1, 0 }) -- jump into the blank line
			end
			vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
				pattern = "*.md",
				callback = function()
					vim.bo.filetype = "quarto"
				end,
				desc = "Treat .md files as quarto for code running",
			})

			vim.keymap.set("n", "<leader>nc", insert_new_cell, { desc = "Insert [n]ew [c]ell", silent = true })
			vim.keymap.set("n", "<leader>rc", runner.run_cell, { desc = "run cell", silent = true })
			vim.keymap.set("n", "<leader>ra", runner.run_above, { desc = "run cell and above", silent = true })
			vim.keymap.set("n", "<leader>rA", runner.run_all, { desc = "run all cells", silent = true })
			vim.keymap.set("n", "<leader>rl", runner.run_line, { desc = "run line", silent = true })
			vim.keymap.set("v", "<leader>r", runner.run_range, { desc = "run visual range", silent = true })
			vim.keymap.set("n", "<leader>RA", function()
				runner.run_all(true)
			end, { desc = "run all cells of all languages", silent = true })
			vim.keymap.set("n", "<leader>nc", insert_new_cell, { desc = "Insert [n]ew [c]ell", silent = true })
			vim.keymap.set("n", "<leader>rc", runner.run_cell, { desc = "run cell", silent = true })
			vim.keymap.set("n", "<leader>ra", runner.run_above, { desc = "run cell and above", silent = true })
			vim.keymap.set("n", "<leader>rA", runner.run_all, { desc = "run all cells", silent = true })
			vim.keymap.set("n", "<leader>rl", runner.run_line, { desc = "run line", silent = true })
			vim.keymap.set("v", "<leader>r", runner.run_range, { desc = "run visual range", silent = true })
			vim.keymap.set("n", "<leader>RA", function()
				runner.run_all(true)
			end, { desc = "run all cells of all languages", silent = true })

			-- 🧠 Default notebook template (for .ipynb files)
			-- Default .ipynb content
			local default_notebook = [[
{
  "cells": [
    {
      "cell_type": "markdown",
      "metadata": {},
      "source": [""]
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

			-- Create a new notebook and open it in Neovim
			local function new_notebook(filename)
				local path = filename:match("%.ipynb$") and filename or (filename .. ".ipynb")
				local file = io.open(path, "w")
				if file then
					file:write(default_notebook)
					file:close()
					vim.cmd("edit " .. path)
				else
					vim.notify("Failed to create notebook: " .. path, vim.log.levels.ERROR)
				end
			end

			-- User command to create a new notebook safely
			vim.api.nvim_create_user_command("NewNotebook", function(opts)
				new_notebook(opts.args)
			end, {
				nargs = 1,
				complete = "file",
			})
			-- 🧙 Autocmd to auto-populate new *.ipynb files
			vim.api.nvim_create_autocmd("BufWritePre", {
				pattern = "*.ipynb",
				callback = function(args)
					local file = args.file
					local stat = vim.loop.fs_stat(file)
					local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
					local is_empty = (#lines == 1 and lines[1] == "")

					if not stat and is_empty then
						vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(default_notebook, "\n"))
						vim.notify("Inserted default notebook metadata into " .. file, vim.log.levels.INFO)
					end
				end,
				desc = "Insert notebook template before saving new .ipynb file",
			})
		end,
		dependencies = {
			-- for language features in code cells
			-- configured in lua/plugins/lsp.lua
			"jmbuhr/otter.nvim",
		},
	},

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

	{ -- send code from python/r/qmd documets to a terminal or REPL
		-- like ipython, R, bash
		"jpalardy/vim-slime",
		dev = false,
		init = function()
			vim.b["quarto_is_python_chunk"] = false
			Quarto_is_in_python_chunk = function()
				require("otter.tools.functions").is_otter_language_context("python")
			end

			vim.cmd([[
      let g:slime_dispatch_ipython_pause = 100
      function SlimeOverride_EscapeText_quarto(text)
      call v:lua.Quarto_is_in_python_chunk()
      if exists('g:slime_python_ipython') && len(split(a:text,"\n")) > 1 && b:quarto_is_python_chunk && !(exists('b:quarto_is_r_mode') && b:quarto_is_r_mode)
      return ["%cpaste -q\n", g:slime_dispatch_ipython_pause, a:text, "--", "\n"]
      else
      if exists('b:quarto_is_r_mode') && b:quarto_is_r_mode && b:quarto_is_python_chunk
      return [a:text, "\n"]
      else
      return [a:text]
      end
      end
      endfunction
      ]])

			vim.g.slime_target = "neovim"
			vim.g.slime_no_mappings = true
			vim.g.slime_python_ipython = 1
		end,
		config = function()
			vim.g.slime_input_pid = false
			vim.g.slime_suggest_default = true
			vim.g.slime_menu_config = false
			vim.g.slime_neovim_ignore_unlisted = true

			local function mark_terminal()
				local job_id = vim.b.terminal_job_id
				vim.print("job_id: " .. job_id)
			end

			local function set_terminal()
				vim.fn.call("slime#config", {})
			end
			vim.keymap.set("n", "<leader>cm", mark_terminal, { desc = "[m]ark terminal" })
			vim.keymap.set("n", "<leader>cs", set_terminal, { desc = "[s]et terminal" })
		end,
	},

	{ -- paste an image from the clipboard or drag-and-drop
		"HakonHarnes/img-clip.nvim",
		event = "BufEnter",
		ft = { "markdown", "quarto", "latex" },
		opts = {
			default = {
				dir_path = "img",
			},
			filetypes = {
				markdown = {
					url_encode_path = true,
					template = "![$CURSOR]($FILE_PATH)",
					drag_and_drop = {
						download_images = false,
					},
				},
				quarto = {
					url_encode_path = true,
					template = "![$CURSOR]($FILE_PATH)",
					drag_and_drop = {
						download_images = false,
					},
				},
			},
		},
		config = function(_, opts)
			require("img-clip").setup(opts)
			vim.keymap.set("n", "<leader>ii", ":PasteImage<cr>", { desc = "insert [i]mage from clipboard" })
		end,
	},

	{ -- preview equations
		"jbyuki/nabla.nvim",
		keys = {
			{ "<leader>qm", ':lua require"nabla".toggle_virt()<cr>', desc = "toggle [m]ath equations" },
		},
	},

	{
		"benlubas/molten-nvim",
		dev = false,
		enabled = true,
		version = "^1.0.0", -- use version <2.0.0 to avoid breaking changes
		build = ":UpdateRemotePlugins",
		init = function()
			vim.g.molten_image_provider = "image.nvim"
			-- vim.g.molten_output_win_max_height = 20
			vim.g.molten_auto_open_output = true
			vim.g.molten_auto_open_html_in_browser = true
			vim.g.molten_tick_rate = 200
		end,
		config = function()
			local init = function()
				local quarto_cfg = require("quarto.config").config
				quarto_cfg.codeRunner.default_method = "molten"
				vim.cmd([[MoltenInit]])
			end
			local deinit = function()
				local quarto_cfg = require("quarto.config").config
				quarto_cfg.codeRunner.default_method = "slime"
				vim.cmd([[MoltenDeinit]])
			end
			vim.keymap.set("n", "<leader>mi", init, { silent = true, desc = "Initialize molten" })
			vim.keymap.set("n", "<leader>md", deinit, { silent = true, desc = "Stop molten" })
			vim.keymap.set("n", "<leader>mp", ":MoltenImagePopup<CR>", { silent = true, desc = "molten image popup" })
			vim.keymap.set(
				"n",
				"<leader>mb",
				":MoltenOpenInBrowser<CR>",
				{ silent = true, desc = "molten open in browser" }
			)
			vim.keymap.set("n", "<leader>mh", ":MoltenHideOutput<CR>", { silent = true, desc = "hide output" })
			vim.keymap.set(
				"n",
				"<leader>ms",
				":noautocmd MoltenEnterOutput<CR>",
				{ silent = true, desc = "show/enter output" }
			)
		end,
	},
}
