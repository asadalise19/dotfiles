return {
  "nickjvandyke/opencode.nvim",
  version = "*",
  dependencies = {
    "folke/snacks.nvim",
  },
  opts = function()
    local socket = assert(vim.uv.new_tcp())
    assert(socket:bind("127.0.0.1", 0))
    local kilocode_port = socket:getsockname().port
    socket:close()
    local kilocode_password = vim.fn.sha256(("%s:%s"):format(vim.uv.hrtime(), vim.fn.getpid()))
    local kilocode_pane_id = nil
    local kilocode_visible = false

    local function pane_exists()
      if not kilocode_pane_id then
        return false
      end
      local check = vim.fn.system("tmux has-session -t " .. kilocode_pane_id .. " 2>/dev/null; echo $?")
      if vim.trim(check) == "0" then
        return true
      end
      kilocode_pane_id = nil
      kilocode_visible = false
      return false
    end

    local function start()
      if pane_exists() and kilocode_visible then
        return
      end

      if pane_exists() then
        vim.fn.system("tmux join-pane -h -l 35% -s " .. kilocode_pane_id)
      else
        local command = ("KILO_SERVER_USERNAME=opencode KILO_SERVER_PASSWORD=%s kilocode --port %d"):format(
          kilocode_password,
          kilocode_port
        )
        local result = vim.fn.system("tmux split-window -h -p 35 -P -F '#{pane_id}' '" .. command .. "'")
        kilocode_pane_id = vim.trim(result)
      end
      kilocode_visible = true
    end

    local function stop()
      if not pane_exists() then
        return
      end
      vim.fn.system("tmux send-keys -t " .. kilocode_pane_id .. " C-c")
      vim.defer_fn(function()
        vim.fn.system("tmux kill-pane -t " .. kilocode_pane_id)
        kilocode_pane_id = nil
        kilocode_visible = false
      end, 500)
    end

    local function toggle()
      if not pane_exists() then
        start()
      elseif kilocode_visible then
        vim.fn.system("tmux break-pane -d -s " .. kilocode_pane_id)
        kilocode_visible = false
      else
        vim.fn.system("tmux join-pane -h -l 35% -s " .. kilocode_pane_id)
        kilocode_visible = true
      end
    end

    return {
      server = {
        url = "http://127.0.0.1:" .. kilocode_port,
        username = "opencode",
        password = kilocode_password,
        start = start,
        stop = stop,
        toggle = toggle,
      },
      ask = {
        prompt = "Ask KiloCode: ",
      },
      select = {
        prompt = "KiloCode: ",
      },
    }
  end,
  config = function(_, opts)
    vim.g.opencode_opts = opts

    vim.o.autoread = true
  end,
  keys = {
    {
      "<leader>oa",
      function()
        require("opencode").ask("@this: ")
      end,
      desc = "Ask KiloCode",
      mode = { "n", "x" },
    },
    {
      "<leader>oc",
      function()
        require("opencode").select()
      end,
      desc = "KiloCode commands/prompts",
      mode = { "n", "x" },
    },
    {
      "go",
      function()
        return require("opencode").operator("@this ")
      end,
      desc = "Append range to KiloCode",
      expr = true,
      mode = { "n", "x" },
    },
    {
      "goo",
      function()
        return require("opencode").operator("@this ") .. "_"
      end,
      desc = "Append line to KiloCode",
      expr = true,
    },
    {
      "<leader>os",
      function()
        vim.g.opencode_opts.server.start()
      end,
      desc = "KiloCode start pane",
    },
    {
      "<leader>ot",
      function()
        vim.g.opencode_opts.server.toggle()
      end,
      desc = "KiloCode toggle pane",
    },
    {
      "<leader>oq",
      function()
        vim.g.opencode_opts.server.stop()
      end,
      desc = "KiloCode quit pane",
    },
  },
}
