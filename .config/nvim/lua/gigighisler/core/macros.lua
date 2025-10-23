local function set_macro(register, keys)
  local processed = vim.api.nvim_replace_termcodes(keys, true, false, true)
  vim.fn.setreg(register, processed)
end

-- Python
vim.api.nvim_create_augroup("PythonMacros", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = "PythonMacros",
  pattern = "python",
  callback = function()
    set_macro("l", "yoprint(\"<Esc>pa:<Esc>ei, <Esc>p")
  end,
})

-- JavaScript/TypeScript
vim.api.nvim_create_augroup("JSMacros", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = "JSMacros",
  pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
  callback = function()
    set_macro("l", "yoconsole.log('<Esc>pa:<Esc>ei, <Esc>p")
  end,
})
