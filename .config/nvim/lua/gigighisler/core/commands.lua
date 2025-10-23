vim.api.nvim_create_user_command("RevealInFinder", function()
	vim.cmd("!open -R %")
end, {})

vim.api.nvim_create_user_command("OpenInVSCode", function()
	local path = vim.fn.expand("%:p:h")
	vim.cmd("!code --reuse-window " .. path)
end, {})

function SwitchAvanteModel(model)
	vim.g.current_avante_model = model
	require("avante").setup({
		provider = "copilot",
		copilot = {
			endpoint = "https://api.githubcopilot.com",
			model = model,
			proxy = nil,
			allow_insecure = false,
			timeout = 30000,
			temperature = 0,
		},
	})
	print("✅ Switched Avante model to: " .. model)
end

-- Command to change models on the fly
vim.api.nvim_create_user_command("AvanteSwitchModel", function(args)
	SwitchAvanteModel(args.args)
end, {
	nargs = 1,
	complete = function()
		return { "claude-sonnet-4", "claude-3.7-sonnet", "gpt-4.1", "gpt-4-turbo", "gpt-3.5-turbo" }
	end,
})

-- Optional: Show current model
vim.api.nvim_create_user_command("AvanteCurrentModel", function()
	print("📌 Current Avante model: " .. (vim.g.current_avante_model or "Not Set"))
end, {})
