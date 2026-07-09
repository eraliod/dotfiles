# Capture flow

The inverse of `/todo` (which infers aggressively and rarely asks). A thin
achievement note is useless downstream, so ASK when detail is missing.

1. **Gather** everything from the command argument and the current conversation.
2. **Detect gaps** against what outputs need:
   - HARD (must resolve before writing): at least one **quantified metric**, a
     clear **what-you-personally-did**, an identifiable **date or span**.
   - SOFT (ask if cheap): scope (team/cross-team/company-wide), key
     decisions/trade-offs.
3. **Ask, batched, metrics first.** Use AskUserQuestion. Quantified results carry
   resume bullets, so push for numbers: "now it performs well" -> "By how much —
   runtime, cost, rows, error rate?" Accept "no hard number" for small
   pattern-only achievements (see below).
4. **Draft and confirm BEFORE writing.** Present: proposed title + filename slug,
   the headline, a compact summary of Context/Action/Result, and the
   competency + technology tags. Let the user edit any of it inline. Do not write
   until they approve.
5. **Write** to `~/Documents/legion/achievements/YYYY-MM-DD-<slug>.md`, honoring
   the sentence caps in `note-schema.md`.
6. **Bootstrap on first run:** if `~/Documents/legion/achievements/` has no
   `README.md`, create it (template below) before writing the note.
7. **Report** the path and remind the user to run `/legion` to sync. Never run
   git against the vault.

## Small / pattern-only achievements

Some achievements (e.g. mentoring a colleague through a setup) will not become a
standalone resume bullet. Do NOT force a metric. Tag the competency
(`#mentorship`, `#leadership`) and, in the report, note this is a _pattern
contributor_ that strengthens a theme when grouped with similar notes.

## README bootstrap template

Write this to `~/Documents/legion/achievements/README.md` on first run:

```markdown
# Achievements

Terse, structured records of technical achievements, used to build
self-reviews, resume bullets, and STAR interview answers.

## Naming

Flat directory. Files are `YYYY-MM-DD-<slug>.md`, where the date is the
achievement's milestone/completion date and the slug is the headline,
kebab-cased.

## Note structure

YAML frontmatter (title, date, optional date_end/ongoing, logged, scope,
metrics, tags) plus a compact STAR body: a one-sentence Headline, then Context
(<=3 sentences), Action (<=5), Result (<=4), then inline #tags.

## Tags

Competency tags are a small controlled set (#leadership, #mentorship,
#architecture, #reliability, #performance, #cost-savings, #delivery,
#data-quality, #automation); technology tags are free-form. Tags appear in both
the frontmatter and inline.

## Subdirectories

- `reviews/` — saved self-review drafts.
- `resume-drafts/` — resume material tailored to specific roles.
- `resume-base.md` — the master resume (hand-maintained).

## Syncing

These notes are created by the `achievements` Claude Code plugin. They are NOT
auto-committed. Run `/legion` to sync the vault.
```
