---
description: Draft a self-review for a time period by synthesizing achievement notes from the legion vault
argument-hint: <period, e.g. "H1 2026", "2026", "last 6 months", or a date range>
allowed-tools: Bash(date:*), Read, Glob, Write, AskUserQuestion, Skill
---

# Draft a self-review

Synthesize achievement notes into review-ready prose for a period. Load the
`achievements` skill first; use `references/output-guides.md` for rendering.

## Context

- Today's date: !`date +%Y-%m-%d`
- Achievement directory: `~/Documents/legion/achievements/`
- Requested period: **$ARGUMENTS**

## Steps

1. **Load the skill** (Skill tool).
2. **Resolve the period** from `$ARGUMENTS`. Accept `H1 2026`, `H2 2026`,
   `Q2 2026`, `2026`, `last N months`, or `YYYY-MM-DD..YYYY-MM-DD`. If blank, ask
   (default: the current half-year).
3. **Select notes by overlap.** Glob `~/Documents/legion/achievements/*.md`, read
   each note's frontmatter, and include it if its `date`..`date_end` span (a
   point if no `date_end`) overlaps the resolved window. Ongoing notes whose span
   reaches into the window count.
4. **Cluster by competency tag.** Group selected notes under their controlled
   competency tags. Several small same-competency notes form one theme.
5. **Draft the review.** For each theme, write 1-2 short paragraphs leading with
   impact and weaving in numbers from `metrics`. Prose, not a list of notes.
6. **Show coverage.** List which notes fed each theme; flag competencies with no
   notes this period and whether the period is thin.
7. **Output to chat by default.** Then offer to save to
   `~/Documents/legion/achievements/reviews/<YYYY>-self-review-<period>.md`. If
   saved, remind the user to run `/legion`. Do not run git against the vault.
