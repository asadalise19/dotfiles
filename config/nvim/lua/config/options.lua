-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.number = true
vim.opt.backupcopy = "yes"
vim.opt.relativenumber = false
vim.opt.clipboard = "unnamedplus"
vim.opt.fillchars:append({ eob = " " })
vim.opt.smartcase = true
vim.opt.ignorecase = true
-- vim.opt.mouse = ""
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("state") .. "/undo"
vim.opt.autoread = true
vim.opt.wrap = true
vim.opt.linebreak = true
