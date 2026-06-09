# Refactor: Adopt team data-dotfiles structure

**Date:** 2026-06-09
**Target version:** v3.0.0 (major — restructures repo + introduces marketplace)
**Reference repo:** `/Users/damian.eralio/documents/code/data-dotfiles`

## Goal

Restructure `~/dotfiles` to mirror the team's `data-dotfiles` layout (GNU Stow for symlink management, a Claude plugin marketplace, declarative Brewfile) while preserving personal choices the team's defaults don't match.

## Relationship to team repo

**Independent repo, same shape.** Not a fork, no upstream rebase dance. Team improvements are pulled in manually when desired.

## Target directory layout

```
~/dotfiles/
├── .claude-plugin/marketplace.json          # marketplace: "dotfile-plugins"
├── .github/                                  # existing CI
├── .gitignore
├── .pre-commit-config.yaml
├── install.sh                                # rewritten: stow + scripts/setup orchestrator
├── README.md                                 # rewritten
│
├── docs/
│   └── plans/
│       └── 2026-06-09-team-dotfiles-refactor-design.md  # this file
│
├── packages/
│   └── Brewfile                              # replaces brew.sh content
│
├── plugins/
│   ├── excalidraw-preview/
│   │   ├── .claude-plugin/plugin.json
│   │   ├── hooks/hooks.json                  # PostToolUse on mcp__excalidraw__create_view
│   │   ├── scripts/{ensure-server,serve,write-preview}.sh
│   │   └── index.html
│   ├── redshift-mcp/
│   │   ├── .claude-plugin/plugin.json
│   │   └── .mcp.json                         # legacy + analytics-dev + analytics-prod
│   └── databricks-mcp-custom/
│       ├── .claude-plugin/plugin.json
│       ├── .mcp.json                         # personal Databricks profiles
│       └── hooks/
│           ├── hooks.json                    # PreToolUse → token-check
│           ├── databricks-mcp-token-check.sh
│           └── databricks-mcp-proxy
│
├── scripts/
│   └── setup/
│       ├── brew.sh                           # runs `brew bundle --file=../../packages/Brewfile`
│       ├── claude.sh                         # NO more `claude mcp add redshift-*` (now plugin)
│       ├── git.sh
│       ├── ohmyzsh.sh
│       ├── pixi.sh
│       └── vscode.sh
│
└── stow/
    ├── aws/.aws/config                       # personal (preserved as-is this iteration)
    ├── claude/.claude/
    │   ├── settings.json                     # PRESERVES inline statusline, permissions, hooks
    │   ├── CLAUDE.md                         # wrapper: @~/.claude/base.md
    │   ├── base.md                           # content (@./jira_instructions.md)
    │   └── jira_instructions.md
    ├── databricks/.databrickscfg
    ├── pixi/.pixi/manifests/pixi-global.toml # PRESERVES awscli here
    ├── shell/
    │   ├── .aliases                          # merged with team
    │   ├── .zshrc                            # p10k preserved, uv completion added
    │   └── .zprofile                         # identical to team, no merge
    └── vscode/Library/Application Support/Code/User/settings.json
```

## Preservations (locked)

| Concern                  | Team has it as...                      | Personal keeps...                   |
| ------------------------ | -------------------------------------- | ----------------------------------- |
| AWS CLI                  | `brew "awscli"` in Brewfile            | In `pixi-global.toml`               |
| Statusline               | Separate `statusline-command.sh` file  | Inline one-liner in `settings.json` |
| Shell theme              | Spaceship                              | p10k                                |
| Claude permissions/hooks | Team defaults                          | Personal set (revisit later)        |
| AWS config               | Tracked, with `*-readonly` SSO pattern | Personal config (revisit later)     |
| `.zprofile`              | Team version                           | Identical — no merge                |

## Plugins (marketplace: `dotfile-plugins`)

### `excalidraw-preview`

- **Source:** `settings/claude/excalidraw-preview/` + the PostToolUse hook currently in `settings.json`
- **Description:** Local browser preview for Excalidraw MCP diagrams

### `redshift-mcp`

- **Source:** Three `claude mcp add` calls in `claude.sh:96-101`
- **Replaces:** Imperative MCP registration with declarative `.mcp.json`
- **Servers:** `redshift-legacy` (legacy SSO, us-east-1), `redshift-analytics-dev` (analytics-dev SSO, us-east-2), `redshift-analytics-prod` (analytics-prod SSO, us-east-2)

### `databricks-mcp-custom`

- **Source:** `databricks-mcp-token-check.sh` + `databricks-mcp-proxy` + Damian's Databricks MCP profiles
- **Description:** Personal Databricks MCP profiles with OAuth token expiry check

## Stow packages

`shell`, `claude`, `pixi`, `vscode`, `aws`, `databricks` — all six.

## File merges

### `.aliases` (post-merge)

- Existing personal: `ch`, `hg`, `python`, `pip`, `cat=bat`, `update_system`, `update_brew`, `clean`, `gitkeyfix`, `trc`
- Pulled from team: `trci`, `trcp`, `trca` (other terramate aliases)
- **Moved from `.zshrc` Functions block**: `ap`, `dp`, `get-uuid`
- **Both kept**: `gbdg` (yours, dry-run) + `gbda` (team's, auto-delete)

### `.zshrc` (post-merge)

- Keep: p10k theme + instant prompt, current plugins (aliases, command-not-found, git, docker), pixi PATH, pixi completion, fzf, terraform/terramate/terragrunt completions, terramate settings, thefuck alias, dotfiles source loop
- **Remove**: Functions block (moved to `.aliases`)
- **Add from team**: `eval "$(uv generate-shell-completion zsh)"` only
- **Skip from team**: Spaceship theme, `~/.local/bin` + `~/.cargo/bin` PATH, pixi auto-activate, `DATABRICKS_CLI_PATH` workaround
- **Source order swap**: change `~/.{private,aliases}` → `~/.{aliases,private}` so private overrides aliases (matches team)

### `pixi-global.toml`

- Diff against team's, keep personal entries (especially `awscli`)

### `packages/Brewfile`

- Convert from `brew.sh` imperative commands
- **Exclude**: `awscli` (stays in pixi)

### `stow/claude/.claude/settings.json`

- **Remove**: Excalidraw PostToolUse hook, Databricks token-check PreToolUse hook (move into plugins)
- **Add**: `enabledPlugins` entries for `dotfile-plugins/{excalidraw-preview,redshift-mcp,databricks-mcp-custom}` + marketplace reference
- **Keep**: inline statusline, all other permissions/hooks (revisit team merge later)

## Implementation: 7 atomic commits in a worktree

| #   | Commit message                                   | Risk     | Summary                                                            |
| --- | ------------------------------------------------ | -------- | ------------------------------------------------------------------ |
| 1   | `feat: scaffold marketplace + plugin shells`     | None     | Empty marketplace.json + 3 plugin.json files                       |
| 2   | `feat(excalidraw-preview): extract as plugin`    | Low      | Move scripts/html + hook                                           |
| 3   | `feat(redshift-mcp): extract as plugin`          | Low      | Add .mcp.json, remove claude.sh lines                              |
| 4   | `feat(databricks-mcp-custom): extract as plugin` | Low      | Move token-check, add .mcp.json                                    |
| 5   | `refactor: adopt stow + scripts/setup layout`    | **High** | The big move — stow/, scripts/setup/, Brewfile, install.sh rewrite |
| 6   | `chore: delete legacy files`                     | Low      | Remove old settings/, root .sh scripts                             |
| 7   | `docs: rewrite README for new structure`         | None     | Team-style README                                                  |

### Worktree

Work in `~/dotfiles-refactor` on branch `refactor/team-dotfiles-structure`. Validate `./install.sh --stow-only` end-to-end before merging back to `main`.

### Switch-over (manual, post-merge)

After merging back to main, the live `~/.zshrc` etc. are still real files. Run `./install.sh --force` to back them up and replace with symlinks. The `.backup/<timestamp>/` is the safety net.

## Follow-ups (NOT this refactor — flagged for later)

1. **Merge team Claude permissions/hooks into `settings.json`.** Current iteration keeps personal set intact.
2. **AWS readonly profile pattern.** Adopt the team idea of paired profiles (`analytics-dev` for CLI work via `KinPowerUser`, `analytics-dev-readonly` for Claude via `ReadOnly`). Limits Claude to read-only AWS via SSO permissions rather than ad-hoc command allowlists.
3. **Investigate `DATABRICKS_CLI_PATH` workaround.** Team has `export DATABRICKS_CLI_PATH="$HOME/.pixi/envs/databricks-cli/bin/databricks"` to bypass SDK rejection of pixi's trampoline binary. Damian hasn't hit this issue — confirm whether needed.
4. **MCP migration note**: Existing user-scope MCP entries from previous `claude mcp add redshift-*` calls live in `~/.claude.json`. The plugin won't conflict, but the duplicates should be removed via `claude mcp remove redshift-legacy` (etc.) on the live machine after commit 3 lands.
