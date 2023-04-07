-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- It doesnt not work :/
vim.keymap.set("i", "<S-tab>", "<C-V><tab>", { desc = "shift tab to insert an actual tab character" })
