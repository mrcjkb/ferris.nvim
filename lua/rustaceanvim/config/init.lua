---@mod rustaceanvim.config plugin configuration
---
---@brief [[
---
---rustaceanvim is a filetype plugin, and does not need
---a `setup` function to work.
---
---To configure rustaceanvim, set the variable `vim.g.rustaceanvim`,
---which is a `RustaceanOpts` table, in your neovim configuration.
---
---Example:
---
--->lua
------@type RustaceanOpts
---vim.g.rustaceanvim = {
---   ---@type RustaceanToolsOpts
---   tools = {
---     -- ...
---   },
---   ---@type RustaceanLspClientOpts
---   server = {
---     on_attach = function(client, bufnr)
---       -- Set keybindings, etc. here.
---     end,
---     settings = {
---       -- rust-analyzer language server configuration
---       ['rust-analyzer'] = {
---       },
---     },
---     -- ...
---   },
---   ---@type RustaceanDapOpts
---   dap = {
---     -- ...
---   },
--- }
---<
---
---Notes:
---
--- - `vim.g.rustaceanvim` can also be a function that returns a `RustaceanOpts` table.
--- - `server.settings`, by default, is a function that looks for a `rust-analyzer.json` file
---    in the project root, to load settings from it. It falls back to an empty table.
---
---@brief ]]

local M = {}

---@type RustaceanOpts | fun():RustaceanOpts | nil
vim.g.rustaceanvim = vim.g.rustaceanvim

---@class RustaceanOpts
---@field tools? RustaceanToolsOpts Plugin options
---@field server? RustaceanLspClientOpts Language server client options
---@field dap? RustaceanDapOpts Debug adapter options

---@class RustaceanToolsOpts
---@field executor? RustaceanExecutor | executor_alias
---@field on_initialized? fun(health:RustAnalyzerInitializedStatus) Function that is invoked when the LSP server has finished initializing
---@field reload_workspace_from_cargo_toml? boolean Automatically call `RustReloadWorkspace` when writing to a Cargo.toml file
---@field hover_actions? RustaceanHoverActionsOpts Options for hover actions
---@field create_graph? RustaceanCrateGraphConfig Options for showing the crate graph based on graphviz and the dot

---@class RustaceanHoverActionsOpts
---@field replace_builtin_hover? boolean Whether to replace Neovim's built-in `vim.lsp.buf.hover`
---@field border? string[][] See `vim.api.nvim_open_win`
---@field max_width? integer | nil Maximum width of the hover window (`nil` means no max.)
---@field max_height? integer | nil Maximum height of the hover window (`nil` means no max.)
---@field auto_focus? boolean Whether to automatically focus the hover action window

---@alias lsp_server_health_status 'ok' | 'warning' | 'error'

---@class RustAnalyzerInitializedStatus
---@field health lsp_server_health_status

---@class RustaceanCrateGraphConfig
---@field backend? string Backend used for displaying the graph. See: https://graphviz.org/docs/outputs/ Defaults to `"x11"` if unset.
---@field output? string Where to store the output. No output if unset. Relative path from `cwd`.
---@field enabled_graphviz_backends? string[] Override the enabled graphviz backends list, used for input validation and autocompletion.
---@field pipe? string Overide the pipe symbol in the shell command. Useful if using a shell that is not supported by this plugin.

---@class RustaceanLspClientOpts
---@field auto_attach? boolean | fun():boolean Whether to automatically attach the LSP client. Defaults to `true` if the `rust-analyzer` executable is found.
---@field cmd? string[] | fun():string[] Command and arguments for starting rust-analyzer
---@field settings? fun(project_root:string|nil):table | table Setting passed to rust-analyzer. Defaults to a function that looks for a `rust-analyzer.json` file or returns an empty table. See https://rust-analyzer.github.io/manual.html#configuration.
---@field standalone? boolean Standalone file support (enabled by default). Disabling it may improve rust-analyzer's startup time.

---@class RustaceanDapOpts
---@field adapter? DapExecutableConfig | DapServerConfig | disable | fun():(DapExecutableConfig | DapServerConfig | disable) Defaults to a `DapServerConfig` if `codelldb` is detected, and to a `DapExecutableConfig` if `lldb` is detected. Set to `false` to disable.
---@field auto_generate_source_map fun():boolean | boolean Whether to auto-generate a source map for the standard library.

---@alias disable false

---@alias DapCommand string

---@class DapExecutableConfig
---@field type dap_adapter_type_executable The type of debug adapter.
---@field command string Default: `"lldb-vscode"`.
---@field args? string Default: unset.
---@field name? string Default: `"lldb"`.

---@class DapServerConfig
---@field type dap_adapter_type_server The type of debug adapter.
---@field host? string The host to connect to.
---@field port string The port to connect to.
---@field executable DapExecutable The executable to run
---@field name? string

---@class DapExecutable
---@field command string The executable.
---@field args string[] Its arguments.

---@alias dap_adapter_type_executable "executable"
---@alias dap_adapter_type_server "server"

return M
