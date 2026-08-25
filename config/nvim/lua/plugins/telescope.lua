return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      cond = function()
        return vim.fn.executable("make") == 1
      end,
    },
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local image = require("snacks.image")
    local image_buf = require("snacks.image.buf")

    telescope.setup({
      defaults = {
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--hidden",
        },
        prompt_prefix = "  ",
        selection_caret = " ",
        entry_prefix = "  ",
        initial_mode = "insert",
        selection_strategy = "reset",
        sorting_strategy = "ascending",
        layout_strategy = "horizontal",
        layout_config = {
          prompt_position = "top",
          height = 0.8,
          width = 0.75,
          horizontal = {
            preview_width = 0.55,
            mirror = false,
          },
          vertical = {
            mirror = true,
            preview_cutoff = 1,
            prompt_position = "top",
            height = 0.95, -- Relative height of the Telescope window
            width = 0.6, -- Relative width of the Telescope window
          },
        },
        file_sorter = require("telescope.sorters").get_fuzzy_file,
        file_ignore_patterns = { "^%.git/" },
        generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
        path_display = { "truncate" },
        winblend = 0,
        border = {},
        -- borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
        color_devicons = true,
        use_less = true,
        set_env = { ["COLORTERM"] = "truecolor" },
        file_previewer = require("telescope.previewers").vim_buffer_cat.new,
        grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
        qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
        buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
        preview = {
          filetype_hook = function(filepath, bufnr, _)
            if not image.supports_file(filepath) then
              return true
            end

            image_buf.attach(bufnr, { src = filepath })
            return false
          end,
        },
        mappings = {
          i = {
            ["<C-h>"] = actions.preview_scrolling_left,
            ["<C-l>"] = actions.preview_scrolling_right,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
          },
          n = {
            ["<C-h>"] = actions.preview_scrolling_left,
            ["<C-l>"] = actions.preview_scrolling_right,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
          },
        },
      },
      pickers = {
        find_files = {
          hidden = true,
          find_command = { "rg", "--files", "--hidden", "--glob", "!.git/*" },
        },
      },
    })

    pcall(telescope.load_extension, "fzf")
  end,
}
