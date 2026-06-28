---
name: achievements
description: Use when capturing a work achievement, writing a self-review for a period, or producing/tailoring resume material from a job description. Defines where achievement notes live, the note schema, the tag vocabulary, and the terseness philosophy shared by the /achievement, /self-review, /resume-bullets, and /resume commands.
---

# Achievements

Capture technical achievements as terse, structured markdown, then reuse them
for self-reviews, resume bullets, and STAR interview prep. This skill holds the
invariants; the four commands are thin entry points.

## Where notes live

All notes are written to the Obsidian "legion" vault:

- Achievement notes: `~/Documents/legion/achievements/YYYY-MM-DD-<slug>.md`
- Saved self-reviews: `~/Documents/legion/achievements/reviews/`
- Tailored resume drafts: `~/Documents/legion/achievements/resume-drafts/`
- The user's master resume: `~/Documents/legion/achievements/resume-base.md`

Always use the literal `~/Documents/legion` prefix. **Never** run a `git`
command against the vault — after writing files, tell the user to run `/legion`
to sync.

## Core philosophy: terse, but reconstructable

Notes must be short enough that capture is cheap, but structured enough that the
same note can produce a resume bullet, a review paragraph, and a STAR answer.
The body follows a compact STAR with hard sentence caps (see
`references/note-schema.md`). Never write verbose notes.

## The note schema

See `references/note-schema.md` for the full frontmatter + body spec and caps.

## Tags

See `references/tag-vocabulary.md`. Competency tags are a controlled vocabulary
(pick 1-3); technology tags are free-form. Tags appear in BOTH frontmatter
`tags:` and inline `#tags` at the body bottom, kept in sync.

## Shared protocols

- Capturing a new achievement: `references/capture-flow.md`.
- Rendering outputs (resume bullets / review prose / STAR): `references/output-guides.md`.

## Honesty guardrail (downstream commands)

Resume and review output must use only facts present in the notes. When a job
description asks for something with no matching achievement, name it as a gap —
never fabricate. Existing user-written resume bullets are trusted prose and may
be reworded; anything added or quantified must trace to a logged achievement.
