return {
	"hrsh7th/nvim-cmp",
	event = "InsertEnter",
	dependencies = {
		"hrsh7th/cmp-buffer", -- source for text in buffer
		"hrsh7th/cmp-path", -- source for file system paths
		{
			"L3MON4D3/LuaSnip",
			-- follow latest release.
			version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
			-- install jsregexp (optional!).
			build = "make install_jsregexp",
		},
		"saadparwaiz1/cmp_luasnip", -- for autocompletion
		"rafamadriz/friendly-snippets", -- useful snippets
		"onsails/lspkind.nvim", -- vs-code like pictograms
	-- 	{
	-- 		"zbirenbaum/copilot-cmp",
	-- 		dependencies = { "zbirenbaum/copilot.lua" },
	-- 		config = function(_, opts)
	-- 			local copilot_cmp = require("copilot_cmp")
	-- 			copilot_cmp.setup(opts)
	--
	-- 			-- Attach Copilot CMP source on InsertEnter to support lazy-loading
	-- 			vim.api.nvim_create_autocmd("InsertEnter", {
	-- 				callback = function()
	-- 					if package.loaded["copilot"] then
	-- 						copilot_cmp._on_insert_enter({})
	-- 					end
	-- 				end,
	-- 			})
	-- 		end,
	-- 		opts = {},
	-- 	},
	},
	config = function()
		local cmp = require("cmp")

		local luasnip = require("luasnip")

		local lspkind = require("lspkind")

		-- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
		require("luasnip.loaders.from_vscode").lazy_load()

		cmp.setup({
			completion = {
				completeopt = "menu,menuone,preview,noselect",
			},
			snippet = { -- configure how nvim-cmp interacts with snippet engine
				expand = function(args)
					luasnip.lsp_expand(args.body)
				end,
			},
			mapping = cmp.mapping.preset.insert({
				["<C-k>"] = cmp.mapping.select_prev_item(), -- previous suggestion
				["<C-j>"] = cmp.mapping.select_next_item(), -- next suggestion
				["<C-b>"] = cmp.mapping.scroll_docs(-4),
				["<C-f>"] = cmp.mapping.scroll_docs(4),
				["<C-Space>"] = cmp.mapping.complete(), -- show completion suggestions
				["<C-e>"] = cmp.mapping.abort(), -- close completion window
				["<CR>"] = cmp.mapping.confirm({ select = false }),
			}),
			-- sources for autocompletion
			sources = cmp.config.sources({
				-- { name = "copilot", group_index = 1, priority = 100 },
				{ name = "nvim_lsp" },
				{ name = "luasnip" }, -- snippets
				{ name = "buffer" }, -- text within current buffer
				{ name = "path" }, -- file system paths
			}),

			-- configure lspkind for vs-code like pictograms in completion menu
			formatting = {
				format = function(entry, vim_item)
					-- Use lspkind icons
					vim_item = lspkind.cmp_format({
						maxwidth = 50,
						ellipsis_char = "...",
					})(entry, vim_item)

					-- Custom label for Copilot
					if entry.source.name == "copilot" then
						vim_item.kind = " Copilot"
						vim_item.kind_hl_group = "CmpItemKindCopilot"
					end

					return vim_item
				end,
			},
		})
	end,
}

