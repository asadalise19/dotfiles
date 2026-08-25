return {
  "mbbill/undotree",
  cmd = "UndotreeToggle",
  init = function()
    vim.g.undotree_WindowLayout = 3
    vim.keymap.set("n", "<leader>uu", "<cmd>UndotreeToggle<CR>", { desc = "UndoTree toggler" })
  end,
}
