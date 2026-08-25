return {
  {
    "okuuva/auto-save.nvim",
    event = { "InsertLeave", "TextChanged", "TextChangedI", "TextChangedP" },
    opts = {
      trigger_events = {
        defer_save = { "InsertLeave", "TextChanged", "TextChangedI", "TextChangedP" },
      },
      debounce_delay = 1000,
      condition = function(buf)
        -- Exclude claudecode diff buffers by buffer name patterns
        local bufname = vim.api.nvim_buf_get_name(buf)
        if
          bufname:match("%(proposed%)")
          or bufname:match("%(NEW FILE %- proposed%)")
          or bufname:match("%(New%)")
        then
          return false
        end

        -- Exclude by buffer variables (claudecode sets these)
        if
          vim.b[buf].claudecode_diff_tab_name
          or vim.b[buf].claudecode_diff_new_win
          or vim.b[buf].claudecode_diff_target_win
        then
          return false
        end

        -- Exclude by buffer type (claudecode diff buffers use "acwrite")
        local buftype = vim.fn.getbufvar(buf, "&buftype")
        if buftype == "acwrite" then
          return false
        end

        return true -- Safe to auto-save
      end,
    },
  },
}
