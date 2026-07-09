---
description: Capture a work achievement as a terse, structured markdown note in the legion vault
argument-hint: <the achievement, or leave blank to use conversation context>
allowed-tools: Bash(date:*), Read, Write, Glob, AskUserQuestion, Skill
---

# Capture an achievement

Record a technical achievement as a terse, reusable note. Load the
`achievements` skill first and follow its `references/capture-flow.md` exactly.

## Context

- Today's date: !`date +%Y-%m-%d`
- Achievement directory: `~/Documents/legion/achievements/`
- Raw input from the user: **$ARGUMENTS**

## Steps

1. **Load the skill.** Invoke the `achievements` skill (Skill tool) to load the
   note schema, tag vocabulary, and capture protocol.
2. **Run the capture flow** in `references/capture-flow.md`:
   - Gather from `$ARGUMENTS` + this conversation.
   - Detect gaps; if any HARD requirement is missing (a quantified metric, a
     clear what-you-did, a date/span), ask via AskUserQuestion — metrics first.
     Allow metric-free capture only for small pattern-only achievements.
   - Draft and present title+slug, headline, a compact Context/Action/Result
     summary, and competency+tech tags. **Wait for approval. Do not write yet.**
3. **Bootstrap** the achievements directory README if it does not exist (template
   in `capture-flow.md`).
4. **Write** the note to
   `~/Documents/legion/achievements/<today>-<slug>.md`, honoring the schema and
   sentence caps (Headline 1, Context <=3, Action <=5, Result <=4). Keep
   frontmatter `tags:` (bare) and inline `#tags` carrying the same set.
5. **Report** the path written and a one-line summary, note whether it is a
   standalone bullet or a pattern contributor, and remind the user to run
   `/legion` to sync. Do not run git against the vault.
