# Achievement note schema

Path: `~/Documents/legion/achievements/YYYY-MM-DD-<slug>.md`. The date is the
primary/milestone date; the slug is the headline kebab-cased.

```markdown
---
title: Config-driven DLT ingestion framework
date: 2026-01-15 # milestone / completion / "when it mattered"
date_end: 2026-02-20 # optional — spans only
ongoing: true # optional — still evolving
logged: 2026-06-28 # when captured (today)
scope: company-wide # team | cross-team | company-wide
metrics: # quantified wins; [] if genuinely none
  - "new-source onboarding: weeks -> <1 hour"
  - "MVP delivered in 5 weeks"
tags: [databricks, ingestion, iac, leadership] # competency + tech, mirrors body
---

# Config-driven DLT ingestion framework

**Headline:** <=1 sentence — a draft resume bullet: action verb + win + number.

## Context

<=3 sentences. Situation + your mandate (the S+T of STAR).

## Action

<=5 sentences. What _you_ did and the key decisions/trade-offs.

## Result

<=4 sentences. Outcome, adoption, quantified impact, career effect.

#leadership #ingestion #databricks #iac
```

## Rules

- **Sentence caps are enforced at capture, not suggested.** Headline 1, Context
  <=3, Action <=5, Result <=4.
- **Large-achievement exception.** For framework/library-scale work (designing
  an entire framework, platform, or library), each body section's cap may be
  raised by +3: Context <=6, Action <=8, Result <=7. Headline stays 1 — it is
  the resume bullet. This room is ONLY for large achievements and ONLY with the
  user's explicit go-ahead: ask at capture time, never assume.
- **Action framing — decisions, not inventory.** For any achievement with an
  architecture element (and all large projects), Action is a narrative of
  design forks: each sentence = a fork + the road not taken + why. A feature
  inventory proves nothing about the author — "for all they know, another
  person made all the decisions." Include maturity markers when true:
  reversing your own earlier design when evidence changed; applying one
  consistent decision framework under review pressure, with rationale posted.
  Keep a FEW technical highlights that show depth in service of the team
  (advanced techniques powering a team capability) — a few, never a list.
  Outcomes belong in Result as proof the decisions held, not as the story.
- **No `role` field** — titles don't travel across companies. `scope` captures
  blast radius, which is an objective, company-relative claim.
- **`metrics` mirrors the numbers in Result** so resume commands grab quantified
  wins without re-parsing prose. Empty list allowed but discouraged — see the
  pattern-only exception in `capture-flow.md` (the one case where `[]` is fine).
- **Tags appear twice** — frontmatter `tags:` (machine-queryable) and inline
  `#tags` at body bottom (Obsidian-native). The two must carry the **same set**
  of tags (order-independent). **Frontmatter tags are bare** (`databricks`);
  **inline tags carry `#`** (`#databricks`). Never put `#` inside the frontmatter
  array.

## Date model

- `date` — primary/milestone date; drives the filename.
- `date_end` + `ongoing: true` — optional, for work spanning time.
- `logged` — the capture date (today).
- **Selection is by overlap:** a note belongs to a period if its
  `date`..`date_end` span (a point if no `date_end`) overlaps the period window.
  A year-long effort appears in every period it was active.
