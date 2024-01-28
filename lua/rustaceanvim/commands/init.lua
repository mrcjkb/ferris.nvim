---@mod rustaceanvim.commands

local config = require('rustaceanvim.config.internal')

---@class RustaceanCommands
local M = {}

local rust_lsp_cmd_name = 'RustLsp'

---@type { string: fun(args: string[], opts: vim.api.keyset.user_command) }
local command_tbl = {
  codeAction = function(_)
    require('rustaceanvim.commands.code_action_group')()
  end,
  crateGraph = function(args)
    require('rustaceanvim.commands.crate_graph')(unpack(args))
  end,
  debuggables = function(args, opts)
    if opts.bang then
      require('rustaceanvim.cached_commands').execute_last_debuggable()
    else
      require('rustaceanvim.commands.debuggables').debuggables(args)
    end
  end,
  expandMacro = function(_)
    require('rustaceanvim.commands.expand_macro')()
  end,
  explainError = function(_)
    require('rustaceanvim.commands.diagnostic').explain_error()
  end,
  renderDiagnostic = function(_)
    require('rustaceanvim.commands.diagnostic').render_diagnostic()
  end,
  rebuildProcMacros = function()
    require('rustaceanvim.commands.rebuild_proc_macros')()
  end,
  externalDocs = function(_)
    require('rustaceanvim.commands.external_docs')()
  end,
  hover = function(args)
    if #args == 0 then
      vim.notify("hover: called without 'actions' or 'range'", vim.log.levels.ERROR)
      return
    end
    local subcmd = args[1]
    if subcmd == 'actions' then
      require('rustaceanvim.hover_actions').hover_actions()
    elseif subcmd == 'range' then
      require('rustaceanvim.commands.hover_range')()
    else
      vim.notify('hover: unknown subcommand: ' .. subcmd .. " expected 'actions' or 'range'", vim.log.levels.ERROR)
    end
  end,
  runnables = function(args, opts)
    if opts.bang then
      require('rustaceanvim.cached_commands').execute_last_runnable()
    else
      require('rustaceanvim.runnables').runnables(args)
    end
  end,
  joinLines = function(_)
    require('rustaceanvim.commands.join_lines')()
  end,
  moveItem = function(args)
    if #args == 0 then
      vim.notify("moveItem: called without 'up' or 'down'", vim.log.levels.ERROR)
      return
    end
    if args[1] == 'down' then
      require('rustaceanvim.commands.move_item')()
    elseif args[1] == 'up' then
      require('rustaceanvim.commands.move_item')(true)
    else
      vim.notify(
        'moveItem: unexpected argument: ' .. vim.inspect(args) .. " expected 'up' or 'down'",
        vim.log.levels.ERROR
      )
    end
  end,
  openCargo = function(_)
    require('rustaceanvim.commands.open_cargo_toml')()
  end,
  parentModule = function(_)
    require('rustaceanvim.commands.parent_module')()
  end,
  ssr = function(args)
    local query = args and #args > 0 and table.concat(args, ' ') or nil
    require('rustaceanvim.commands.ssr')(query)
  end,
  reloadWorkspace = function()
    require('rustaceanvim.commands.workspace_refresh')()
  end,
  syntaxTree = function()
    require('rustaceanvim.commands.syntax_tree')()
  end,
  flyCheck = function(args)
    local cmd = args[1] or 'run'
    require('rustaceanvim.commands.fly_check')(cmd)
  end,
  rustcUnpretty = function(args)
    local arg = args[1]:lower()
    local available = false
    for _, value in ipairs(require('rustaceanvim.commands.rustc_unpretty').available_unpretty) do
      if value == arg then
        available = true
        break
      end
    end
    if not available or not args or #args == 0 then
      local err_msg = table.concat(require('rustaceanvim.commands.rustc_unpretty').available_unpretty, ' | ')
      vim.notify('Expected argument list: ' .. err_msg, vim.log.levels.ERROR)
      return
    end

    require('rustaceanvim.commands.rustc_unpretty').rustc_unpretty(arg)
  end,
  view = function(args)
    if not args or #args == 0 then
      vim.notify("Expected argument: 'mir' or 'hir'", vim.log.levels.ERROR)
      return
    end
    local level
    local arg = args[1]:lower()
    if arg == 'mir' then
      level = 'Mir'
    elseif arg == 'hir' then
      level = 'Hir'
    else
      vim.notify('Unexpected argument: ' .. arg .. " Expected: 'mir' or 'hir'", vim.log.levels.ERROR)
      return
    end
    require('rustaceanvim.commands.view_ir')(level)
  end,
  logFile = function()
    vim.cmd.e(config.server.logfile)
  end,
}

---@param opts table
---@see vim.api.nvim_create_user_command
local function rust_lsp(opts)
  local fargs = opts.fargs
  local cmd = fargs[1]
  local args = #fargs > 1 and vim.list_slice(fargs, 2, #fargs) or {}
  local command = command_tbl[cmd]
  if not command then
    vim.notify(rust_lsp_cmd_name .. ': Unknown subcommand: ' .. cmd, vim.log.levels.ERROR)
    return
  end
  command(args, opts)
end

---Create the `:RustLsp` command
function M.create_rust_lsp_command()
  vim.api.nvim_create_user_command(rust_lsp_cmd_name, rust_lsp, {
    nargs = '+',
    range = true,
    bang = true,
    desc = 'Interacts with the rust-analyzer LSP client',
    complete = function(arg_lead, cmdline, _)
      local commands = vim.tbl_keys(command_tbl)
      local match_start = '^' .. rust_lsp_cmd_name .. '[!]*'
      local subcmd_match = '%s+%w*$'
      -- special case: crateGraph comes with graphviz backend completions
      if
        cmdline:match(match_start .. '%sdebuggables' .. subcmd_match)
        or cmdline:match(match_start .. '%srunnables%s+%w*$')
      then
        return { 'last' }
      end
      if cmdline:match(match_start .. '%shover' .. subcmd_match) then
        return { 'actions', 'range' }
      end
      if cmdline:match(match_start .. '%smoveItem' .. subcmd_match) then
        return { 'up', 'down' }
      end
      if cmdline:match(match_start .. '%scrateGraph' .. subcmd_match) then
        return config.tools.crate_graph.enabled_graphviz_backends or {}
      end
      if cmdline:match(match_start .. '%sflyCheck' .. subcmd_match) then
        return { 'run', 'clear', 'cancel' }
      end
      if cmdline:match(match_start .. '%sview' .. subcmd_match) then
        return { 'mir', 'hir' }
      end
      if cmdline:match(match_start .. '%srustcUnpretty' .. subcmd_match) then
        return require('rustaceanvim.commands.rustc_unpretty').available_unpretty
      end
      if cmdline:match(match_start .. '%s+%w*$') then
        return vim.tbl_filter(function(command)
          return command:find(arg_lead) ~= nil
        end, commands)
      end
    end,
  })
end

--- Delete the `:RustLsp` command
function M.delete_rust_lsp_command()
  vim.api.nvim_del_user_command(rust_lsp_cmd_name)
end

return M
