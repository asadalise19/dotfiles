return {
  "nickjvandyke/opencode.nvim",
  version = "*",
  config = function()
    local opencode_pane_id = nil
    local opencode_visible = false

    local function tmux(args)
      table.insert(args, 1, "tmux")
      return vim.system(args, { text = true }):wait()
    end

    local server_password = vim.env.OPENCODE_SERVER_PASSWORD
    if not server_password or server_password == "" then
      local generated = vim.system({ "openssl", "rand", "-hex", "32" }, { text = true }):wait()
      server_password = vim.trim(generated.stdout or "")
      if generated.code ~= 0 or #server_password ~= 64 or not server_password:match("^%x+$") then
        server_password = nil
      end
    end

    local function pane_exists()
      if not opencode_pane_id then
        return false
      end

      local result = tmux({ "display-message", "-p", "-t", opencode_pane_id, "#{pane_id}" })
      if result.code == 0 and vim.trim(result.stdout or "") == opencode_pane_id then
        return true
      end

      opencode_pane_id = nil
      opencode_visible = false
      return false
    end

    local function start()
      if not vim.env.TMUX or vim.fn.executable("tmux") == 0 or vim.fn.executable("opencode") == 0 then
        vim.notify("OpenCode pane requires tmux and the opencode executable", vim.log.levels.ERROR)
        return
      end

      if not server_password then
        vim.notify("Unable to generate an OpenCode server password", vim.log.levels.ERROR)
        return
      end

      if pane_exists() and opencode_visible then
        return
      end

      if pane_exists() then
        local result = tmux({ "join-pane", "-h", "-l", "35%", "-s", opencode_pane_id })
        if result.code ~= 0 then
          vim.notify("Unable to attach the OpenCode pane", vim.log.levels.ERROR)
          return
        end
      else
        local result = tmux({
          "split-window",
          "-e",
          "OPENCODE_SERVER_PASSWORD=" .. server_password,
          "-h",
          "-p",
          "35",
          "-P",
          "-F",
          "#{pane_id}",
          "opencode --port",
        })
        local pane_id = vim.trim(result.stdout or "")
        if result.code ~= 0 or not pane_id:match("^%%%d+$") then
          vim.notify("Unable to start the OpenCode pane", vim.log.levels.ERROR)
          return
        end
        opencode_pane_id = pane_id
      end
      opencode_visible = true
    end

    local function stop()
      if not pane_exists() then
        return
      end

      local pane_id = opencode_pane_id
      opencode_pane_id = nil
      opencode_visible = false
      tmux({ "send-keys", "-t", pane_id, "C-c" })
      vim.defer_fn(function()
        tmux({ "kill-pane", "-t", pane_id })
      end, 500)
    end

    local function toggle()
      if not pane_exists() then
        start()
      elseif opencode_visible then
        local result = tmux({ "break-pane", "-d", "-s", opencode_pane_id })
        if result.code ~= 0 then
          vim.notify("Unable to detach the OpenCode pane", vim.log.levels.ERROR)
          return
        end
        opencode_visible = false
      else
        local result = tmux({ "join-pane", "-h", "-l", "35%", "-s", opencode_pane_id })
        if result.code ~= 0 then
          vim.notify("Unable to attach the OpenCode pane", vim.log.levels.ERROR)
          return
        end
        opencode_visible = true
      end
    end

    vim.g.opencode_opts = {
      server = {
        password = server_password,
        start = start,
        stop = stop,
        toggle = toggle,
      },
    }

    vim.o.autoread = true
  end,
  keys = {
    {
      "<leader>oa",
      function()
        require("opencode").ask("@this: ")
      end,
      desc = "Ask OpenCode",
      mode = { "n", "x" },
    },
    {
      "<leader>oc",
      function()
        require("opencode").select()
      end,
      desc = "Select OpenCode",
      mode = { "n", "x" },
    },
    {
      "go",
      function()
        return require("opencode").operator("@this ")
      end,
      desc = "Append range to OpenCode",
      expr = true,
      mode = { "n", "x" },
    },
    {
      "goo",
      function()
        return require("opencode").operator("@this ") .. "_"
      end,
      desc = "Append line to OpenCode",
      expr = true,
    },
    {
      "<S-C-u>",
      function()
        require("opencode").command("session.half.page.up")
      end,
      desc = "Scroll OpenCode up",
    },
    {
      "<S-C-d>",
      function()
        require("opencode").command("session.half.page.down")
      end,
      desc = "Scroll OpenCode down",
    },
    {
      "<leader>os",
      function()
        vim.g.opencode_opts.server.start()
      end,
      desc = "OpenCode start pane",
    },
    {
      "<leader>ot",
      function()
        vim.g.opencode_opts.server.toggle()
      end,
      desc = "OpenCode toggle pane",
    },
    {
      "<leader>oq",
      function()
        vim.g.opencode_opts.server.stop()
      end,
      desc = "OpenCode quit pane",
    },
  },
}
