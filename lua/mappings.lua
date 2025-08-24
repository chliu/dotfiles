require "nvchad.mappings"

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Lua mappings
map("n", "<space><space>x", "<cmd>source %<CR>")
map("n","<space>x",".lua<CR>")
map("v","<space>x",":lua<CR>")

-- Quick Save and Quit
map("n", "<leader>w", ":w<CR>")
map("n", "<leader>q", ":q<CR>")
