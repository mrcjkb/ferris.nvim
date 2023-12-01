<!-- markdownlint-disable MD024 -->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `:RustLsp logFile` command, which opens the rust-analyzer log file.
- `:RustLsp flyCheck`: Support `run`, `clear` and `cancel` subcommands.
- Executors: Support commands without `cwd`.

### Fixed

- Health: Check if `vim.g.rustaceanvim` is set,
  but hasn't been sourced before initialization.

## [3.7.1] - 2023-11-28

### Fixed

- DAP: Correctly format environment, so that it works with both `codelldb`
  and `lldb` [[#74](https://github.com/mrcjkb/rustaceanvim/pull/74)].
  Thanks [@richchurcher](https://github.com/richchurcher)!

## [3.7.0] - 2023-11-27

### Added

- DAP: Support dynamically compiled executables [[#64]https://github.com/mrcjkb/rustaceanvim/pull/64).
  Thanks [@richchurcher](https://github.com/richchurcher)!
  - Configures dynamic library paths by default (with the ability to disable)
  - Loads Rust type information by default (with the ability to disable).

### Fixed

- DAP: Format `sourceMap` correctly for both `codelldb` and `lldb`.
  `codelldb` expects a map, while `lldb` expects a list of tuples.

## [3.6.5] - 2023-11-22

### Fixed

- Completion for `:RustLsp hover actions` command suggesting `action`.

## [3.6.4] - 2023-11-19

### Fixed

## [3.6.3] - 2023-11-18

- DAP: Source map should be a list of tuples, not a map.

### Fixed

- DAP: `lldb-vscode` and `lldb-dap` executable detection.

## [3.6.2] - 2023-11-17

### Fixed

- DAP: Add support for `lldb-dap`,
  which has been renamed to `lldb-vscode`, but may still have the
  old name on some distributions.

## [3.6.1] - 2023-11-17

### Fixed

- Broken `:RustLsp runnables last` command [[#62](https://github.com/mrcjkb/rustaceanvim/issues/62)].

## [3.6.0] - 2023-11-15

### Added

- Add `tools.open_url` option,
  to allow users to override how to open external docs.

## [3.5.1] - 2023-11-13

### Fixed

- Config validation fails if `server.settings` option is a table [[#56](https://github.com/mrcjkb/rustaceanvim/issues/56)].

## [3.5.0] - 2023-11-11

### Added

- Ability to load rust-analyzer settings from project-local JSON files.

## [3.4.2] - 2023-11-11

### Fixed

- Open external docs broken in Neovim 0.9 [[#50](https://github.com/mrcjkb/rustaceanvim/issues/50)].

## [3.4.1] - 2023-11-10

### Fixed

- Command completion broken in Neovim 0.9 [[#47](https://github.com/mrcjkb/rustaceanvim/issues/47)].

## [3.4.0] - 2023-11-01

### Added

- Auto-create `codelldb` configurations.

### Fixed

- DAP: Support `codelldb` configurations [[#40](https://github.com/mrcjkb/rustaceanvim/issues/40)].
- DAP: Don't pass in an empty source map table if the
  `auto_generate_source_map` setting evaluates to `false`.

## [3.3.3] - 2023-10-31

### Fixed

- Default rust-analyzer configuration [[#37](https://github.com/mrcjkb/rustaceanvim/issues/37)].
  Thanks again, [@eero-lehtinen](https://github.com/eero-lehtinen)!

## [3.3.2] - 2023-10-31

### Fixed

- Cargo workspace reload using removed command [[#36](https://github.com/mrcjkb/rustaceanvim/pull/36)].
  Thanks [@eero-lehtinen](https://github.com/eero-lehtinen)!

## [3.3.1] - 2023-10-31

### Fixed

- Neovim 0.9 compatibility layer: Missing `nil` checks [[#32](https://github.com/mrcjkb/rustaceanvim/issues/32)].

## [3.3.0] - 2023-10-30

### Added

- DAP: Auto-generate source map, to allow stepping into `std`.

## [3.2.1] - 2023-10-29

### Fixed

- `dap`/`quickfix` executor: Fix setting `cwd` for shell commands.

## [3.2.0] - 2023-10-29

### Added

- Completions for `:RustLsp` subcommands' arguments.

### Changed

- Removed `plenary.nvim` dependency (`dap` and `quickfix` executor).
  This plugin now has no `plenary.nvim` dependencies left.
  NOTE: As this does **not** lead to a bump in the minimal requirements,
  this is not a breaking change.

## [3.1.1] - 2023-10-28

### Fixed

- Remove accidental use of Neovim nightly API
  (`dap`, `crateGraph`, `explainError`) [[#26](https://github.com/mrcjkb/rustaceanvim/issues/26)].
- Add static type checking for Neovim stable API.

## [3.1.0] - 2023-10-28

### Added

- `:RustLsp explainError` command, uses `rustc --explain` on error diagnostics with
  an error code.
- `:RustLsp rebuildProcMacros` command.

### Fixed

- Health check got stuck if `lldb-vscode` was installed.

## [3.0.4] - 2023-10-25

### Fixed

- Allow `:RustLsp hover range` to accept a range.
- Fix `:RustLsp crateGraph` passing arguments as list.

## [3.0.3] - 2023-10-25

### Fixed

- Potential attempt to index `nil` upvalue when sending `workspace/didChangeWorkspaceFolders`
  to LSP server [[#22](https://github.com/mrcjkb/rustaceanvim/issues/22)].

## [3.0.2] - 2023-10-23

### Fixed

- Hover actions: Tree-sitter syntax highlighting
  in Neovim 0.9 [[#20](https://github.com/mrcjkb/rustaceanvim/issues/20)].

## [3.0.1] - 2023-10-23

### Fixed

- Add support for `workspace/didChangeWorkspaceFolders` to prevent more than one
  rust-analyzer server from spawning per Neovim instance [[#7](https://github.com/mrcjkb/rustaceanvim/issues/7)].
- Neovim 0.9 compatibility [[#9](https://github.com/mrcjkb/rustaceanvim/issues/9)].

## [3.0.0] - 2023-10-22

### Changed

- Renamed this plugin to `rustaceanvim`,
  to avoid potential clashes with [`vxpm/ferris.nvim`](https://github.com/vxpm/ferris.nvim),
  `vxpm/ferris.nvim` was created just before I renamed my fork
  (but after I had checked the web for name clashes (╯°□°)╯︵ ┻━┻).

## [2.1.1] - 2023-10-22

### Fixed

- Open external docs: Use `xdg-open` or `open` (MacOS) by default
  and fall back to `netrw`.
  Remove redundant URL encoding.

## [2.1.0] - 2023-10-22

### Added

- Add a `vim.g.rustaceanvim.server.auto_attach` option, which
  can be a `boolean` or a `fun():boolean` that determines
  whether or not to auto-attach the LSP client when opening
  a Rust file.

### Fixed

- [Internal] Type safety in `RustLsp` command construction.
  This fixes a type error in the `hover` command validation.
- Failure to start on standalone files if `cargo` is not installed.

## [2.0.0] - 2023-10-21

### Breaking changes

- Don't pollute the command space:
  Use a single command with subcommands and completions.
  - `RustAnalyzer [start|stop]`
    (always available in Rust projects)
  - `RustLsp [subcommand]`
    (available when the LSP client is running)
    e.g. `RustLsp moveItem [up|down]`

## [1.0.1] - 2023-10-21

### Fixed

- Hover actions + command cache: module requires.

## [1.0.0] - 2023-10-21

### Added

- Initial release of `rustaceanvim`.
- `:RustSyntaxTree` and `:RustFlyCheck` commands.
- `:RustAnalyzerStart` and `:RustAnalyzerStop` commands.
- Config validation.
- Health checks (`:checkhealth rustaceanvim`).
- Vimdocs (auto-generated from Lua docs - `:help rustaceanvim`).
- Nix flake.
- Allow `tools.executor` to be a string.
- LuaRocks releases.
- Minimal config for troubleshooting.

### Internal

- Added type annotations.
- Nix CI and linting infrastructure and static type checking.
- Lazy load command modules.

### Fixed

- Numerous potential bugs encountered during rewrite.
- Erroneous semantic token highlights.
- Make sure we only send LSP requests to the correct client.

### Breaking changes compared to `rust-tools.nvim`

- [Removed the `setup` function](https://mrcjkb.dev/posts/2023-08-22-setup.html)
  and revamped the architecture to be less prone to type errors.
  This plugin is a filetype plugin and works out of the box.
  The default configuration should work for most people,
  but it can be configured with a `vim.g.rustaceanvim` table.
- Removed the `lspconfig` dependency.
  This plugin now uses the built-in LSP client API.
  You can use `:RustAnalyzerStart` and `:RustAnalyzerStop`
  to manually start/stop the LSP client.
  This plugin auto-starts the client when opening a rust file,
  if the `rust-analyzer` binary is found.
- Removed `rt = require('rust-tools')` table.
  You can access the commands using Neovim's `vim.cmd` Lua bridge,
  for example `:lua vim.cmd.RustSSR()` or `:RustSSR`.
- Bumped minimum Neovim version to `0.9`.
- Removed inlay hints, as this feature will be built into Neovim `0.10`.
