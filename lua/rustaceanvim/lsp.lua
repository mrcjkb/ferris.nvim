local M = {}
---@type RustaceanConfig
local config = require('rustaceanvim.config.internal')

local function override_apply_text_edits()
  local old_func = vim.lsp.util.apply_text_edits
  ---@diagnostic disable-next-line
  vim.lsp.util.apply_text_edits = function(edits, bufnr, offset_encoding)
    local overrides = require('rustaceanvim.overrides')
    overrides.snippet_text_edits_to_text_edits(edits)
    old_func(edits, bufnr, offset_encoding)
  end
end

local function is_library(fname)
  local cargo_home = os.getenv('CARGO_HOME') or vim.fs.joinpath(vim.env.HOME, '.cargo')
  local registry = vim.fs.joinpath(cargo_home, 'registry', 'src')

  local rustup_home = os.getenv('RUSTUP_HOME') or vim.fs.joinpath(vim.env.HOME, '.rustup')
  local toolchains = vim.fs.joinpath(rustup_home, 'toolchains')

  for _, item in ipairs { toolchains, registry } do
    if fname:sub(1, #item) == item then
      local clients = vim.lsp.get_clients { name = 'rust-analyzer' }
      return clients[#clients].config.root_dir
    end
  end
end

local function get_root_dir(fname)
  local reuse_active = is_library(fname)
  if reuse_active then
    return reuse_active
  end
  local cargo_crate_dir = vim.fs.dirname(vim.fs.find({ 'Cargo.toml' }, {
    upward = true,
    path = vim.fs.dirname(fname),
  })[1])
  local cargo_workspace_dir = nil
  if vim.fn.executable('cargo') == 1 then
    local cmd = { 'cargo', 'metadata', '--no-deps', '--format-version', '1' }
    if cargo_crate_dir ~= nil then
      cmd[#cmd + 1] = '--manifest-path'
      cmd[#cmd + 1] = vim.fs.joinpath(cargo_crate_dir, 'Cargo.toml')
    end
    local cargo_metadata = ''
    local cm = vim.fn.jobstart(cmd, {
      on_stdout = function(_, d, _)
        cargo_metadata = table.concat(d, '\n')
      end,
      stdout_buffered = true,
    })
    if cm > 0 then
      cm = vim.fn.jobwait({ cm })[1]
    else
      cm = -1
    end
    if cm == 0 then
      cargo_workspace_dir = vim.fn.json_decode(cargo_metadata)['workspace_root']
    end
  end
  return cargo_workspace_dir
    or cargo_crate_dir
    or vim.fs.dirname(vim.fs.find({ 'rust-project.json', '.git' }, {
      upward = true,
      path = vim.fs.dirname(fname),
    })[1])
end

-- Start or attach the LSP client
---@return integer|nil client_id The LSP client ID
M.start = function()
  local client_config = config.server
  local lsp_start_opts = vim.tbl_deep_extend('force', {}, client_config)
  local types = require('rustaceanvim.types.internal')
  local rust_analyzer_cmd = types.evaluate(client_config.cmd)
  if #rust_analyzer_cmd == 0 or vim.fn.executable(rust_analyzer_cmd[1]) ~= 1 then
    vim.notify('rust-analyzer binary not found.', vim.log.levels.ERROR)
    return
  end
  lsp_start_opts.cmd = rust_analyzer_cmd
  lsp_start_opts.name = 'rust-analyzer'
  lsp_start_opts.filetypes = { 'rust' }
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  -- snippets
  capabilities.textDocument.completion.completionItem.snippetSupport = true

  -- output highlights for all semantic tokens
  capabilities.textDocument.semanticTokens.augmentsSyntaxTokens = false

  -- send actions with hover request
  capabilities.experimental = {
    hoverActions = true,
    hoverRange = true,
    serverStatusNotification = true,
    snippetTextEdit = true,
    codeActionGroup = true,
    ssr = true,
  }

  -- enable auto-import
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = { 'documentation', 'detail', 'additionalTextEdits' },
  }

  -- rust analyzer goodies
  capabilities.experimental.commands = {
    commands = {
      'rust-analyzer.runSingle',
      'rust-analyzer.debugSingle',
      'rust-analyzer.showReferences',
      'rust-analyzer.gotoLocation',
      'editor.action.triggerParameterHints',
    },
  }

  lsp_start_opts.capabilities = vim.tbl_deep_extend('force', capabilities, lsp_start_opts.capabilities or {})

  lsp_start_opts.root_dir = get_root_dir(vim.api.nvim_buf_get_name(0))

  local custom_handlers = {}
  custom_handlers['experimental/serverStatus'] = require('rustaceanvim.server_status').handler

  if config.tools.hover_actions.replace_builtin_hover then
    custom_handlers['textDocument/hover'] = require('rustaceanvim.hover_actions').handler
  end

  lsp_start_opts.handlers = vim.tbl_deep_extend('force', custom_handlers, lsp_start_opts.handlers or {})

  local augroup = vim.api.nvim_create_augroup('RustaceanAutoCmds', { clear = true })

  local commands = require('rustaceanvim.commands')
  local old_on_init = lsp_start_opts.on_init
  lsp_start_opts.on_init = function(...)
    override_apply_text_edits()
    commands.create_rust_lsp_command()
    if config.tools.reload_workspace_from_cargo_toml then
      vim.api.nvim_create_autocmd('BufWritePost', {
        pattern = '*/Cargo.toml',
        callback = function()
          vim.cmd.RustReloadWorkspace()
        end,
        group = augroup,
      })
    end
    if type(old_on_init) == 'function' then
      old_on_init(...)
    end
  end

  local old_on_exit = lsp_start_opts.on_exit
  lsp_start_opts.on_exit = function(...)
    override_apply_text_edits()
    commands.delete_rust_lsp_command()
    vim.api.nvim_del_augroup_by_id(augroup)
    if type(old_on_exit) == 'function' then
      old_on_exit(...)
    end
  end

  return vim.lsp.start(lsp_start_opts)
end

---@param bufnr number
---@return lsp.Client[]
local function get_active_rustaceanvim_clients(bufnr)
  return vim.lsp.get_clients { bufnr = bufnr, name = 'rust-analyzer' }
end

---Stop the LSP client.
---@return table[] clients A list of clients that will be stopped
M.stop = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = get_active_rustaceanvim_clients(bufnr)
  vim.lsp.stop_client(clients)
  return clients
end

local function rust_analyzer_cmd(opts)
  local fargs = opts.fargs
  local cmd = fargs[1]
  if cmd == 'start' then
    M.start()
  elseif cmd == 'stop' then
    M.stop()
  end
end

vim.api.nvim_create_user_command('RustAnalyzer', rust_analyzer_cmd, {
  nargs = '+',
  desc = 'Starts or stops the rust-analyzer LSP client',
  complete = function(arg_lead, cmdline, _)
    local commands = {
      'start',
      'stop',
    }
    if cmdline:match('^RustAnalyzer%s+%w*$') then
      return vim
        .iter(commands)
        :filter(function(command)
          return command:find(arg_lead) ~= nil
        end)
        :totable()
    end
  end,
})

return M
