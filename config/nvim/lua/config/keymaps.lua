local map = vim.keymap.set

map("n", "<C-a>", "ggVG$", { desc = "Select all in NORMAL mode" })
map("v", "<C-a>", "<Esc>ggVG$", { desc = "Select all in VISUAL mode" })
map("i", "<C-a>", "<Esc>ggVG$", { desc = "Select all in INSERT mode" })
map("n", ";", ":", { desc = "CMD enter command mode" })
map("n", "<C-s>", ":w<CR>", { desc = "Save file in NORMAL mode" })
map("v", "<C-s>", "<Esc>:w<CR>", { desc = "Save file in VISUAL mode" })
map("i", "<C-s>", "<Esc>:w<CR>", { desc = "Save file in INSERT mode" })
map("n", "<esc>", ":nohlsearch<CR><CR>", { noremap = true, silent = true })
map("n", "<leader>ll", ":Lazy<CR>", { noremap = true, silent = true })
map("n", "<leader>l", "", { noremap = true, silent = true })
map("n", "<leader>lm", ":Mason<CR>", { noremap = true, silent = true })
map("n", "<leader>le", ":LazyExtras<CR>", { noremap = true, silent = true })

map("n", "<leader>lc", function()
  local pos = vim.api.nvim_win_get_cursor(0)
  local bufnr = vim.api.nvim_get_current_buf()
  local diagnostics = vim.diagnostic.get(bufnr, { lnum = pos[1] - 1 })

  if diagnostics and #diagnostics > 0 then
    local msg = diagnostics[1].message
    vim.fn.setreg("+", msg)
    vim.notify(" Copied: " .. msg, vim.log.levels.INFO, { title = "LSP Diagnostic" })
  else
    vim.notify("No diagnostic under cursor", vim.log.levels.WARN, { title = "LSP Diagnostic" })
  end
end, { desc = "Copy LSP diagnostic under cursor" })

map("n", "<leader>hs", ":split<CR>", { desc = "Horizontal split" })
map("n", "<leader>vs", ":vsplit<CR>", { desc = "Vertical split" })

map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>fi", function()
  require("telescope.builtin").find_files({
    prompt_title = "Images",
    hidden = true,
    find_command = {
      "rg",
      "--files",
      "--hidden",
      "--no-ignore",
      "--glob",
      "!.git/*",
      "--iglob",
      "*.png",
      "--iglob",
      "*.jpg",
      "--iglob",
      "*.jpeg",
      "--iglob",
      "*.gif",
      "--iglob",
      "*.webp",
      "--iglob",
      "*.bmp",
      "--iglob",
      "*.svg",
      "--iglob",
      "*.avif",
      "--iglob",
      "*.heic",
      "--iglob",
      "*.tiff",
    },
  })
end, { desc = "Find images" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { noremap = true, silent = true })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { noremap = true, silent = true })
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>fw", function()
  require("telescope.builtin").live_grep({
    layout_strategy = "vertical",
    sorting_strategy = "ascending", -- Ensures first item is at the top
  })
end, { desc = "Live Grep (Vertical Layout)" })
map("n", "<leader>fo", "<cmd>Telescope oldfiles<cr>", { noremap = true, silent = true })

vim.keymap.set("n", "K", function()
  vim.lsp.buf.hover({
    border = "rounded",
    title = " Docs ",
  })
end)

-- Smart text objects for quotes
local function smart_quote(inner)
  return function()
    -- Grab character under cursor
    local c = vim.fn.getline("."):sub(vim.fn.col("."), vim.fn.col("."))
    -- Candidates: double, single, backtick
    local quotes = { '"', "'", "`" }

    -- If cursor is on a quote, use that
    for _, q in ipairs(quotes) do
      if c == q then
        return (inner and "i" or "a") .. q
      end
    end

    -- Otherwise, look backwards for nearest quote on this line
    local line = vim.fn.getline(".")
    local col = vim.fn.col(".")
    local left = line:sub(1, col)
    local found = left:match("[\"'`][^\"'`]*$")
    if found then
      local q = found:sub(1, 1)
      return (inner and "i" or "a") .. q
    end

    -- Fallback: double quotes
    return (inner and 'i"' or 'a"')
  end
end

map({ "o", "x" }, "iq", smart_quote(true), { expr = true })
map({ "o", "x" }, "aq", smart_quote(false), { expr = true })

map("n", "<leader>cc", function()
  local config = { scope = {} }
  config.scope.exclude = { language = {}, node_type = {} }
  config.scope.include = { node_type = {} }

  local node = require("ibl.scope").get(vim.api.nvim_get_current_buf(), config)

  if node then
    local start_row, _, end_row, _ = node:range()
    if start_row ~= end_row then
      vim.api.nvim_win_set_cursor(vim.api.nvim_get_current_win(), { start_row + 1, 0 })
      vim.api.nvim_feedkeys("_", "n", true)
    end
  end
end, { desc = "Blankline Jump to current context" })

