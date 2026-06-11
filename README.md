# Damian's Dotfiles

Personal macOS development environment. Uses [GNU Stow](https://www.gnu.org/software/stow/) for symlink management, [pixi](https://pixi.sh) for CLI tools, and [Homebrew](https://brew.sh) for macOS apps. Bundles a personal Claude Code plugin marketplace (`dotfile-plugins`) for MCP servers and hooks.

Structure mirrors the Kin data team's [data-dotfiles](https://github.com/kin/data-dotfiles) — see [Personal divergences](#personal-divergences) for where this repo deliberately differs.

## Quick Start (Fresh Machine)

```bash
git clone https://github.com/eraliod/dotfiles ~/dotfiles
cd ~/dotfiles && ./install.sh
```

You'll be prompted for your password and git credentials along the way. Restart your terminal when the installer finishes.

## Already Have an Existing Setup?

Use **adopt mode** to pull your current configs into the repo, then diff against the baseline:

```bash
cd ~/dotfiles && ./install.sh --adopt
git diff
```

From there, either accept the repo defaults (`git checkout -- .`) or commit your local additions to a branch.

Use **force mode** to reset to the repo baseline (existing files get backed up to `.backup/<timestamp>/`):

```bash
./install.sh --force
```

## What Gets Installed

- **Homebrew** — formulae, casks, and fonts (see `packages/Brewfile`)
- **Oh My Zsh** — with [Powerlevel10k](https://github.com/romkatv/powerlevel10k) theme
- **pixi** — global CLI tools (see `stow/pixi/.pixi/manifests/pixi-global.toml`), including `awscli`
- **Shell config** — zsh with autocompletions, aliases, helper functions (`ap`, `dp`, `gbdg`, `gbda`, `get-uuid`)
- **VS Code** — settings and extensions
- **Claude Code** — settings, statusline, and the `dotfile-plugins` marketplace

## Claude Code

The installer enables the personal `dotfile-plugins` marketplace, which currently exposes three plugins:

| Plugin                  | What it does                                                                              |
| ----------------------- | ----------------------------------------------------------------------------------------- |
| `excalidraw-preview`    | Local browser preview server for Excalidraw MCP diagrams; PostToolUse writes updates live |
| `redshift-mcp`          | Declarative MCP servers for `redshift-legacy`, `redshift-analytics-dev`, `-prod`          |
| `databricks-mcp-custom` | Personal Databricks MCP profiles + OAuth token expiry check via PreToolUse hook           |

Plugins are referenced from `stow/claude/.claude/settings.json` (`enabledPlugins` and `extraKnownMarketplaces`). Stow symlinks that file to `~/.claude/settings.json` so Claude Code finds them automatically.

### Post-install: existing user-scope MCP entries

If you previously used the old imperative `claude mcp add` flow for Databricks or Redshift servers, those entries still live in `~/.claude.json`. Remove them so the plugin versions take effect:

```bash
claude mcp remove redshift-legacy
claude mcp remove redshift-analytics-dev
claude mcp remove redshift-analytics-prod
claude mcp remove databricks-dbsql-dev
claude mcp remove databricks-dbsql-prod
claude mcp remove databricks-dbsql-sandbox
claude mcp remove databricks-dbsql-adhoc-analysis
```

### Post-install: Databricks auth

The Databricks proxy fetches a fresh OAuth token on each MCP server start via `databricks auth token`. If you see auth errors, run `databricks auth login --profile <PROFILE>` and then `/mcp` in Claude Code to restart the server.

## Personal Divergences

This repo deliberately diverges from data-dotfiles in a few places:

| Concern                  | Team default                           | This repo                                               |
| ------------------------ | -------------------------------------- | ------------------------------------------------------- |
| AWS CLI                  | `brew "awscli"` in Brewfile            | In `stow/pixi/.pixi/manifests/pixi-global.toml`         |
| Statusline               | Separate `statusline-command.sh` file  | Inline one-liner in `stow/claude/.claude/settings.json` |
| Shell theme              | Spaceship                              | Powerlevel10k                                           |
| Claude permissions/hooks | Team defaults                          | Personal set (see follow-ups)                           |
| AWS config               | Tracked, with `*-readonly` SSO pattern | Not tracked yet (see follow-ups)                        |
| `.zprofile`              | Team version                           | Identical                                               |

## Stow Packages

| Package       | Stows to...                                                        |
| ------------- | ------------------------------------------------------------------ |
| `stow/shell`  | `~/.zshrc`, `~/.aliases`, `~/.zprofile`, `~/.p10k.zsh`             |
| `stow/claude` | `~/.claude/{settings.json,CLAUDE.md,base.md,jira_instructions.md}` |
| `stow/pixi`   | `~/.pixi/manifests/pixi-global.toml`                               |
| `stow/vscode` | `~/Library/Application Support/Code/User/settings.json`            |

`stow/aws` and `stow/databricks` are not populated by default. To adopt your existing `~/.aws/config` and `~/.databrickscfg`:

```bash
mkdir -p stow/aws/.aws stow/databricks
./install.sh --adopt
git diff   # review what got pulled in
```

## Manually-Managed Configs

Files in `settings/` are imported by setup scripts rather than stowed:

- `settings/DEC.terminal` — Terminal.app profile (set as default manually)
- `settings/Moom.plist` — Moom window manager settings (imported by `scripts/setup/macOS.sh`)

## Secrets

The installer creates `stow/shell/.private` on first run (gitignored, stowed to `~/.private`, sourced by `.zshrc`). Put API keys, tokens, etc. there:

```bash
# ~/.private
export MY_API_TOKEN="..."
```

## Staying Up to Date

```bash
cd ~/dotfiles && git pull
./install.sh --stow-only   # apply config changes
pixi global sync           # pick up pixi tool version changes
```

If config files are removed from the repo, stow won't clean up the old symlinks — delete dangling symlinks in `~/` manually.

## Post-Installation Manual Steps

1. Restart your terminal (or `source ~/.zshrc`)
2. Set Terminal default profile from `settings/DEC.terminal`
3. Configure Raycast keyboard shortcut (`⌘Space`)
4. Sign in to VS Code extensions (Copilot, GitLens, etc.)
5. (Optional) Adopt `~/.aws/config` and `~/.databrickscfg` via `./install.sh --adopt`
6. Remove stale user-scope MCP entries (see [Claude Code](#claude-code) section)

## License

MIT — see [LICENSE](LICENSE).

## Acknowledgments

Originally forked from [Corey Schafer's dotfiles](https://github.com/CoreyMSchafer/dotfiles), who forked from [Mathias Bynens' dotfiles](https://github.com/mathiasbynens/dotfiles). Structure adopted from the Kin data team's [data-dotfiles](https://github.com/kin/data-dotfiles).
