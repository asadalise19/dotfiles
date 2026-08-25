local tmux_directions = {
  h = { flag = "-L", fallback = "TmuxNavigateLeft" },
  j = { flag = "-D", fallback = "TmuxNavigateDown" },
  k = { flag = "-U", fallback = "TmuxNavigateUp" },
}

local function tmux_select(direction)
  return function()
    local spec = tmux_directions[direction]
    if not spec then
      return
    end

    if not vim.env.TMUX or vim.env.TMUX == "" then
      vim.cmd(spec.fallback)
      return
    end

    local executable = vim.env.TMUX:find("tmate") and "tmate" or "tmux"
    local socket = vim.env.TMUX:match("^[^,]+")
    local cmd = { executable }

    if socket and socket ~= "" then
      vim.list_extend(cmd, { "-S", socket })
    end

    vim.list_extend(cmd, { "select-pane" })
    if vim.env.TMUX_PANE and vim.env.TMUX_PANE ~= "" then
      vim.list_extend(cmd, { "-t", vim.env.TMUX_PANE })
    end
    table.insert(cmd, spec.flag)

    vim.fn.system(cmd)
  end
end

return {
  {
    "folke/snacks.nvim",
    opts = {
      input = {
        enabled = true,
      },
      image = {
        enabled = true,
        doc = {
          enabled = true,
          inline = false,
          float = false,
        },
      },
      picker = {
        enabled = true,
        actions = {
          opencode_send = function(picker)
            local items = vim.tbl_map(function(item)
              return item.file
                and require("opencode").format({ path = item.file, from = item.pos, to = item.end_pos })
                or item.text
            end, picker:selected({ fallback = true }))
            require("opencode").prompt(table.concat(items, ", ") .. " ")
          end,
        },
        win = {
          input = {
            keys = {
              ["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
            },
          },
        },
        icons = {
          git = {
            -- Change type
            added = "✚",
            modified = "",
            -- Status type
            conflict = "",
            unstaged = "", -- File modified
            staged = "", -- File staged
            unmerged = "", -- Merge conflict
            renamed = "➜", -- Renamed file
            untracked = "", -- Untracked file
            deleted = "", -- Deleted file
            ignored = "◌", -- Ignored file
          },
        },
        sources = {
          explorer = {
            -- The explorer owns picker-local <C-h>/<C-j>/<C-k> behavior.
            -- Override those keys inside explorer windows so they escape to
            -- tmux instead of wrapping back into the editor or moving the list.
            win = {
              list = {
                keys = {
                  ["<C-h>"] = { tmux_select("h"), mode = "n", desc = "Go to left tmux pane" },
                  ["<C-j>"] = { tmux_select("j"), mode = "n", desc = "Go to lower tmux pane" },
                  ["<C-k>"] = { tmux_select("k"), mode = "n", desc = "Go to upper tmux pane" },
                },
              },
              preview = {
                keys = {
                  ["<C-h>"] = { tmux_select("h"), mode = "n", desc = "Go to left tmux pane" },
                  ["<C-j>"] = { tmux_select("j"), mode = "n", desc = "Go to lower tmux pane" },
                  ["<C-k>"] = { tmux_select("k"), mode = "n", desc = "Go to upper tmux pane" },
                },
              },
            },
            layout = {
              auto_hide = { "input" }, -- Automatically hides the input/search bar
              layout = {
                width = 30,
                min_width = 30,
              },
            },
          },
        },
      },
    },
  },
}
