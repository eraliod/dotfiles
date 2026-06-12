---
description: Audit accumulated permissions in settings.local.json files and consolidate to global settings
---

# Audit Local Settings

Discover permissions that have accumulated in `settings.local.json` files and consolidate them to global settings.

## Step 1: Discover

Run this script to find all local settings:

```bash
fd -H --no-ignore settings.local.json ~ -E '.claude/plugins' 2>/dev/null | while read -r file; do
  jq -c '{file: $f, permissions: .permissions // {}}' --arg f "$file" "$file" 2>/dev/null
done | jq -s '.'
```

## Step 2: Analyze and Present

For each permission found, categorize and recommend:

| Signal                                  | Recommendation                                 |
| --------------------------------------- | ---------------------------------------------- |
| Appears in 2+ files                     | **Global** (strong) - needed across projects   |
| In `~/.claude/settings.local.json` only | **Global** (default) - not repo-specific       |
| In a specific repo's `.claude/`         | **Keep local** (weak) - might be repo-specific |
| Matches existing global pattern         | **Global** - fits established categories       |

Present findings in three groups:

### Recommend: Consolidate to Global

Permissions that should move to `~/.claude/settings.json`

### Recommend: Keep Local

Permissions tied to specific repos

### Uncertain

Need user input to decide

Include a table for each group showing: Permission | Source(s) | Reasoning

## Step 3: Wildcard Opportunities

Look for verbose rules that could consolidate into wildcards. **Only suggest wildcards when ALL subcommands are safe.**

**Safe to wildcard** (read-only or non-destructive tools):

- `ruff`, `fd`, `rg`, `jq`, `yq`, `pytest`, `ast-grep`

**Never wildcard** (have destructive subcommands):

- `terraform` (apply, destroy)
- `git` (push --force, reset --hard)
- `aws`, `kubectl`, `docker`, `databricks`

**Rule:** If you'd need a deny rule to make the wildcard safe, don't suggest it.

## Step 4: Get Approval

Ask the user which recommendations to accept. They have final say on every permission.

## Step 5: Execute Consolidation

For approved consolidations:

1. **Read** `~/.claude/settings.json`
2. **Show diff** of proposed changes before writing
3. **Merge** approved permissions into appropriate section (allow/ask/deny)
4. **Write** updated global settings
5. **Remove** consolidated permissions from source local files
6. **Clean up** - if a local file becomes empty (`{}` or empty permissions), delete it

**Safety:** Always show diff and confirm before writing. Never touch permissions marked "keep local".
