return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
		{ "williamboman/mason.nvim", opts = {} },
		{
			"williamboman/mason-lspconfig.nvim",
			opts = {
				ensure_installed = { "svelte", "graphql", "emmet_ls", "lua_ls" },
				-- automatic_enable = false,  -- you can disable auto-enable if desired
			},
		},
	},
	config = function()
		local lspconfig = require("lspconfig")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		vim.diagnostic.config({
			virtual_text = false,
			virtual_lines = false,
			signs = true,
			update_in_insert = false,
			float = {
				source = "always", -- show diagnostic source in hover
				border = "rounded",
			},
		})
		vim.keymap.set("n", "<leader>k", function()
			local cfg = vim.diagnostic.config()
			if cfg.virtual_lines == true then
				vim.diagnostic.config({ virtual_lines = false, float = { border = "rounded" } })
			else
				vim.diagnostic.config({ virtual_lines = true, float = { border = "rounded" } })
			end
		end, { desc = "Toggle diagnostics display" })

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				local buf = ev.buf
				local km = vim.keymap.set
				local opts = { buffer = buf, silent = true }

				km(
					"n",
					"gR",
					"<cmd>Telescope lsp_references<CR>",
					vim.tbl_extend("force", opts, { desc = "LSP references" })
				)
				km("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
				km(
					"n",
					"gd",
					"<cmd>Telescope lsp_definitions<CR>",
					vim.tbl_extend("force", opts, { desc = "LSP definitions" })
				)
				km(
					"n",
					"gi",
					"<cmd>Telescope lsp_implementations<CR>",
					vim.tbl_extend("force", opts, { desc = "LSP implementations" })
				)
				km(
					"n",
					"gt",
					"<cmd>Telescope lsp_type_definitions<CR>",
					vim.tbl_extend("force", opts, { desc = "LSP type definitions" })
				)
				km(
					{ "n", "v" },
					"<leader>ca",
					vim.lsp.buf.code_action,
					vim.tbl_extend("force", opts, { desc = "Code action" })
				)
				km("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename" }))
				km(
					"n",
					"<leader>D",
					"<cmd>Telescope diagnostics bufnr=0<CR>",
					vim.tbl_extend("force", opts, { desc = "Buffer diagnostics" })
				)
				km(
					"n",
					"<leader>dl",
					vim.diagnostic.open_float,
					vim.tbl_extend("force", opts, { desc = "Line diagnostics" })
				)
				km("n", "[d", vim.diagnostic.goto_prev, vim.tbl_extend("force", opts, { desc = "Prev diagnostic" }))
				km("n", "]d", vim.diagnostic.goto_next, vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))
				km("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover docs" }))
				km("n", "<leader>rs", ":LspRestart<CR>", vim.tbl_extend("force", opts, { desc = "Restart LSP" }))
			end,
		})

		local capabilities = cmp_nvim_lsp.default_capabilities()

		for type, icon in pairs({ Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }) do
			vim.fn.sign_define("DiagnosticSign" .. type, { text = icon, texthl = "DiagnosticSign" .. type })
		end

		-- Generic default server config
		local default_opts = { capabilities = capabilities }

		-- Specific server configs
		vim.lsp.config(
			"svelte",
			vim.tbl_extend("force", default_opts, {
				on_attach = function(client, bufnr)
					vim.api.nvim_create_autocmd("BufWritePost", {
						pattern = { "*.js", "*.ts" },
						callback = function(ctx)
							client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
						end,
					})
				end,
			})
		)

		vim.lsp.config(
			"graphql",
			vim.tbl_extend("force", default_opts, {
				filetypes = { "python", "go", "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
			})
		)

		vim.lsp.config(
			"emmet_ls",
			vim.tbl_extend("force", default_opts, {
				filetypes = {
					"python",
					"go",
					"html",
					"typescriptreact",
					"javascriptreact",
					"css",
					"sass",
					"scss",
					"less",
					"svelte",
				},
			})
		)

		vim.lsp.config(
			"lua_ls",
			vim.tbl_extend("force", default_opts, {
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
						completion = { callSnippet = "Replace" },
					},
				},
			})
		)
	end,
}
