---
description: Sync the Obsidian "legion" vault to GitHub (commit, rebase-pull, push) with self-healing ignore rules for Obsidian metadata churn
allowed-tools: Bash(git:*), Bash(date:*), Read, Edit
model: claude-haiku-4-5-20251001
---

# Sync the legion vault

Back up and synchronize the Obsidian vault at `~/Documents/legion` with its
GitHub remote. The vault lives at the same path on every machine, so this
command is the single entry point for "save my notes everywhere".

All `git` commands below MUST run against the vault, not the current repo. Use
`git -C ~/Documents/legion ...` for **every** invocation, written with the
literal `~/Documents/legion` path.

**NEVER `cd` into the vault.** The `cd ~/Documents/legion && git ...` form (a)
trips the "changes directory before running git, can execute untrusted hooks"
permission warning and (b) does not match the vault's pre-approved permission
rules, so it prompts on every step. The `git -C ~/Documents/legion ...` form
avoids both. Likewise, do not substitute `$HOME` or an absolute path for `~` —
the permission rules match the literal `~/Documents/legion` prefix.

## Step 0: Verify the vault

Run these checks first and **stop with a clear message** if any fail — do not
proceed to mutate anything:

- `git -C ~/Documents/legion rev-parse --is-inside-work-tree` succeeds.
- `git -C ~/Documents/legion remote get-url origin` contains `legion`.

If the directory is missing or the remote is wrong, report it and stop. Never
operate on the wrong repo.

## Step 1: Self-heal the ignore rules

Obsidian rewrites several files purely as local workspace state (which note had
focus, the recent-files list, deleted notes). These should never sync between
machines, and tracking them is what causes pulls to fail. This step makes the
fix converge automatically on whatever machine runs the command.

The vault `.gitignore` MUST contain these entries (append any that are missing;
never remove existing entries such as `.DS_Store`):

```
# Obsidian local workspace state — do not sync
.obsidian/workspace.json
.obsidian/workspace-mobile.json
.obsidian/workspace
.obsidian/plugins/recent-files-obsidian/data.json
.trash/
```

Then untrack any of those paths that git is **still tracking** (this is the
one-time-per-machine cleanup that `.gitignore` alone cannot do). Do this with
**single** commands — no shell loop, no `cd`:

- List what is still tracked in one call (pass all five paths; it prints only
  the tracked ones):

  ```
  git -C ~/Documents/legion ls-files .obsidian/workspace.json .obsidian/workspace-mobile.json .obsidian/workspace ".obsidian/plugins/recent-files-obsidian/data.json" .trash/
  ```

- If that prints nothing, skip ahead. Otherwise untrack exactly what it printed
  in one call:

  ```
  git -C ~/Documents/legion rm --cached -r --ignore-unmatch <paths it printed>
  ```

The `--cached` flag removes the file from git's index but leaves it on disk, so
Obsidian keeps working. After this commit propagates, other machines drop these
files on their next sync and the ignore rule keeps them out.

## Step 2: Stage everything

Run `git -C ~/Documents/legion add -A` to stage all changes (including the
untracking from Step 1).

## Step 3: Commit the backup

Compute the timestamp in your system timezone, America/New_York:

!`TZ="America/New_York" date "+%Y-%m-%d %H:%M"`

Commit with exactly this message format (use the timestamp above):

```
vault backup YYYY-MM-DD HH:MM
```

If `git -C ~/Documents/legion status --porcelain` shows nothing staged, there is
nothing to commit — **skip the commit** and continue to Step 4 anyway (another
machine may have pushed work you still need to pull).

## Step 4: Pull with rebase

Run `git -C ~/Documents/legion pull --rebase --autostash`.

Because the local work is already committed, the working tree is clean and your
backup commit replays cleanly on top of whatever the remote has. This is what
prevents the "unable to pull due to changed files" problem.

## Step 5: Handle conflicts (stop and ask)

If the rebase reports a conflict:

1. Run `git -C ~/Documents/legion rebase --abort` to restore a clean state.
2. Report which file(s) conflicted (from the rebase output).
3. **Stop. Do not push.** Tell the user the same note was edited on two
   machines and they need to resolve it manually, then re-run `/legion`.

Never auto-resolve conflicts in note content — that risks silently losing
edits.

## Step 6: Push

If the rebase succeeded (or there was nothing to rebase), run
`git -C ~/Documents/legion push`.

## Step 7: Report

Give a short summary:

- Any files that were untracked in Step 1 (only mention if non-empty).
- Whether a backup commit was created (and its message), or "nothing to commit".
- The result of the pull (e.g. "already up to date" or "N files updated").
- The push result.
