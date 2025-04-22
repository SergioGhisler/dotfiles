return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = "VeryLazy",
	config = function()
		local lualine = require("lualine")

		local colors = {
			blue = "#65D1FF",
			green = "#3EFFDC",
			violet = "#FF61EF",
			yellow = "#FFDA7B",
			red = "#FF4A4A",
			fg = "#c3ccdc",
			bg = "#112638",
			inactive_bg = "#2c3043",
			semilightgray = "#7f8490",
		}

		local my_lualine_theme = {
			normal = {
				a = { bg = colors.blue, fg = colors.bg, gui = "bold" },
				b = { bg = colors.bg, fg = colors.fg },
				c = { bg = colors.bg, fg = colors.fg },
			},
			insert = {
				a = { bg = colors.green, fg = colors.bg, gui = "bold" },
				b = { bg = colors.bg, fg = colors.fg },
				c = { bg = colors.bg, fg = colors.fg },
			},
			visual = {
				a = { bg = colors.violet, fg = colors.bg, gui = "bold" },
				b = { bg = colors.bg, fg = colors.fg },
				c = { bg = colors.bg, fg = colors.fg },
			},
			command = {
				a = { bg = colors.yellow, fg = colors.bg, gui = "bold" },
				b = { bg = colors.bg, fg = colors.fg },
				c = { bg = colors.bg, fg = colors.fg },
			},
			replace = {
				a = { bg = colors.red, fg = colors.bg, gui = "bold" },
				b = { bg = colors.bg, fg = colors.fg },
				c = { bg = colors.bg, fg = colors.fg },
			},
			inactive = {
				a = { bg = colors.inactive_bg, fg = colors.semilightgray, gui = "bold" },
				b = { bg = colors.inactive_bg, fg = colors.semilightgray },
				c = { bg = colors.inactive_bg, fg = colors.semilightgray },
			},
		}

		-- Copilot status component
		local copilot_status = {
			function()
				local symbol_on = " "
				local symbol_off = " "

				local ok_api, api = pcall(require, "copilot.api")
				local ok_client, client = pcall(require, "copilot.client")

				if not ok_api or not ok_client then
					return symbol_off .. "N/A"
				end

				if client.is_disabled() then
					return symbol_off .. "Off"
				end

				local status = api.status and api.status.data and api.status.data.status or nil

				if not status or status == "" then
					return symbol_off .. "Offline"
				elseif status == "InProgress" then
					return symbol_on .. "Pending"
				elseif status == "Warning" then
					return symbol_on .. "Warning"
				elseif status == "Normal" then
					return symbol_on .. "Ready"
				end

				return symbol_on .. "Idle"
			end,

			cond = function()
				return pcall(require, "copilot.api") and pcall(require, "copilot.client")
			end,

			color = function()
				local ok, client = pcall(require, "copilot.client")
				if ok and client.is_disabled() then
					return { fg = "#FF4A4A" } -- red for "Off"
				end
				return { fg = "#3EFFDC" } -- green otherwise
			end,
		}
		-- Macro recording status component
		local macro_recording = {
			function()
				local rec = vim.fn.reg_recording()
				if rec == "" then
					return ""
				else
					return "  Recording @" .. rec
				end
			end,
			color = { fg = "#FFDA7B", gui = "bold" },
		}
		-- Setup lualine with Copilot status in lualine_x
		lualine.setup({
			options = {
				theme = my_lualine_theme,
				component_separators = "",
				section_separators = { left = "", right = "" },
			},
			sections = {
				lualine_a = {
					{ "mode", separator = { left = "" }, right_padding = 2 },
				},
				lualine_b = { "branch", "filename" },
				lualine_c = {
					"%=",
				},
				lualine_x = {
					"searchcount",
          macro_recording,
					copilot_status, -- <- Injected Copilot status here
				},
				lualine_y = { "filetype", "progress", "diff" },
				lualine_z = {
					{ "location", separator = { right = "" }, left_padding = 2 },
				},
			},
		})
	end,
}
