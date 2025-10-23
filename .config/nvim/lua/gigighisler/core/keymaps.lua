vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode" }) -- exit insert mode
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window


-- select all with cmd a
keymap.set("n", "<C-A>", "gg<S-v>G", { desc = "Select all" }) -- select all

-- keep things centered!!!!
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")
keymap.set("n", "n", "nzzzv")
keymap.set("n", "N", "Nzzzv")


-- paste and delete without copying
keymap.set("x", "<leader>p", [["_dP]])
keymap.set({"n", "v"}, "<leader>d", [["_d]])

keymap.set("n", "Q", "<nop>")
keymap.set("n", "<leader>sr", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- better indenting
keymap.set("v", "<", "<gv")
keymap.set("v", ">", ">gv")


-- Function to jump to next Databricks cell
local function jump_to_next_cell()
  local pattern = "^# COMMAND ----------"
  if vim.fn.search(pattern, "W") > 0 then  -- W = don't wrap around
    vim.cmd("normal! j")  -- move down one line after finding the pattern
  end
end

-- Function to jump to previous Databricks cell (line after the command)
local function jump_to_prev_cell()
  local pattern = "^# COMMAND ----------"
  local pattern_2 = "^# Databricks notebook source"
  -- First move up a line to avoid finding the current cell
  vim.cmd("normal! k")
  if vim.fn.search(pattern, "bW") > 0 or vim.fn.search(pattern_2, "bW") > 0 then  -- bW = search backwards without wrapping
    vim.cmd("normal! j")  -- move down one line after finding the pattern
  else
    -- If no pattern found, move back to original position
    vim.cmd("normal! j")
  end
end

-- Function to check if file is a Databricks notebook
local function is_databricks_notebook()
  local first_line = vim.fn.getline(1)
  return first_line == "# Databricks notebook source"
end

-- Set up keymaps only for Databricks Python files
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = "*.py",
  callback = function()
    if is_databricks_notebook() then
      vim.keymap.set('n', '<leader>]', jump_to_next_cell, { 
        desc = 'Jump to next Databricks cell',
        buffer = true  -- buffer-local mapping
      })
      vim.keymap.set('n', '<leader>[', jump_to_prev_cell, { 
        desc = 'Jump to previous Databricks cell',
        buffer = true  -- buffer-local mapping
      })
    end
  end,
})
