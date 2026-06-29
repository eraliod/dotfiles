# Achievements plugin — design

A Claude Code plugin for capturing technical achievements as terse, structured
markdown notes in the Obsidian "legion" vault, then synthesizing them into
self-reviews and tailored resume material.

## Problem

Tracking little victories and achievements at work by hand (in Obsidian) is
cumbersome and time-consuming, so it doesn't get done. The downstream tasks
that _need_ those records — writing semi-annual/annual self-reviews, tailoring
a resume to a job description, prepping STAR interview answers — are then even
more painful because there's nothing to parse through. This plugin makes
capture cheap and makes the records reusable.

## Goals

- Make capturing an achievement a single command, with Claude filling in detail
  from context and asking only for what's missing (especially quantified
  results).
- Store achievements as terse markdown — enough to reconstruct STAR, never
  verbose — so the same note feeds resume bullets, review paragraphs, and
  interview answers.
- Synthesize across achievements: a period-bounded self-review, and
  resume material tailored to a job description.
- Capture small achievements (e.g. mentorship) that only matter as part of a
  _pattern_, not as standalone bullets.

## Non-goals

- No database or index — flat markdown files plus frontmatter and tags.
- The commands never sync the vault; `/legion` remains the single sync path.
- No fabrication: resume output is constrained to logged facts; gaps are named,
  not invented.

## Architecture

A new marketplace plugin, `plugins/achievements/`, registered in
`.claude-plugin/marketplace.json` alongside the existing MCP plugins.

```
plugins/achievements/
  .claude-plugin/plugin.json
  skills/
    achievements/
      SKILL.md                 # the shared "brain"
      references/
        note-schema.md         # frontmatter + body spec, with sentence caps
        tag-vocabulary.md      # controlled competency tags + tech-tag rules
        capture-flow.md        # gap-questions + confirm-before-write protocol
        output-guides.md       # rendering: resume bullets / review / STAR
  commands/
    achievement.md             # /achievements:achievement    — capture
    self-review.md             # /achievements:self-review     — synthesize a period
    resume-bullets.md          # /achievements:resume-bullets  — JD -> bullets (MVP)
    resume.md                  # /achievements:resume          — tailor a base resume
```

**Why this split.** The SKILL.md holds everything invariant — where notes live,
the schema, the tag vocabulary, the terseness philosophy. The commands are thin
entry points: each loads the skill, then runs its specific workflow. No
duplication; adding a future workflow (e.g. a 1:1 brag doc) is one more thin
command.

**Vault, not dotfiles.** All notes are written to the legion vault
(`~/Documents/legion`), a separate git repo. The commands write files but
**never** commit the vault — they end by telling the user to run `/legion` to
sync. This keeps one authoritative sync path and avoids two commands touching
that repo.

## Storage map (in the vault)

```
~/Documents/legion/achievements/
  README.md                       # self-documenting (schema, dates, tags, sync)
  YYYY-MM-DD-<slug>.md            # achievement notes (flat)
  resume-base.md                  # markdown master resume (user-maintained)
  reviews/
    YYYY-self-review-<period>.md  # saved self-review drafts
  resume-drafts/
    <role-slug>.md                # tailored resume outputs
```

Organization is **flat + dated + tags**: date is the one immutable,
non-overlapping axis, so it drives the filename; the topical axis (which
overlaps — one achievement spans ingestion + IaC + leadership) is carried by
tags, the Obsidian-native way.

## Achievement note schema

Path: `~/Documents/legion/achievements/YYYY-MM-DD-<slug>.md`, where the date is
the **primary/milestone date** and the slug is the headline kebab-cased.

```markdown
---
title: Config-driven DLT ingestion framework
date: 2026-01-15 # milestone / completion / "when it mattered"
date_end: 2026-02-20 # optional — spans only
ongoing: true # optional — still evolving
logged: 2026-06-28 # auto: when captured (today)
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

**Field rationale.**

- No `role` field: titles don't travel across companies (a "Staff" engineer at
  one is a regular engineer at another). `scope` is kept because blast radius is
  an objective, company-relative claim a reviewer can evaluate.
- `metrics` is a **structured duplicate** of the numbers in Result, so `/resume`
  can grab quantified wins without re-parsing prose. Empty is allowed, but the
  capture flow pushes for at least one.
- Tags live in **both** frontmatter `tags:` (machine-queryable) and inline
  `#tags` at the body bottom (Obsidian click/search). The capture flow keeps
  them in sync.
- Sentence caps are enforced at capture time, not merely suggested. Headline
  stays 1 sentence; Context <=3, Action <=5, Result <=4.

### Date model

Three possible dates exist: when recorded, when the work happened, and the span
it covers. We store the **primary date** (`date`, drives the filename), an
optional `date_end` and `ongoing: true` for spans, and `logged` for the capture
date. Self-review includes a note when its `date`/`date_end` span **overlaps**
the review window — so a year-long framework legitimately appears in every
period it was active.

### Tag strategy

- **Competency tags — controlled vocabulary** (pick 1-3): `#leadership`,
  `#mentorship`, `#architecture`, `#reliability`, `#performance`,
  `#cost-savings`, `#delivery`, `#data-quality`, `#automation`. (Maintained in
  `references/tag-vocabulary.md`; extend deliberately.)
- **Technology tags — free-form**: `#databricks`, `#terraform`, `#postgres`,
  `#aws`, etc.

The controlled competency axis is what lets small same-competency notes be
gathered into a credible pattern; free-form tech tags avoid endless taxonomy
upkeep.

## Commands

### `/achievement` — capture

Inverse of `/todo` ("infer aggressively, rarely ask"): here we ask when detail
is thin, because a thin note isn't usable downstream.

1. **Gather** from the argument + current conversation.
2. **Detect gaps** against what the outputs need. Hard requirements: at least
   one **quantified metric**, a clear **what-you-personally-did**, an
   identifiable **date/span**. Soft: scope, trade-offs/decisions.
3. **Ask, batched** (AskUserQuestion) — quantified results first. (e.g. "now it
   performs well" -> "By how much — runtime, cost, rows, error rate?")
4. **Draft & confirm before writing** — present proposed title+slug, headline, a
   compact summary of all four fields, and competency+tech tags; user edits
   inline.
5. **Write** only after approval, to `YYYY-MM-DD-<slug>.md`.
6. **Bootstrap** the dir + self-documenting README on first run.
7. **Report** the path; remind to run `/legion`.

Small achievements (e.g. the terraform-mentorship case) are not forced to carry
a metric — they get competency-tagged and the report notes they're a _pattern
contributor_, not a standalone bullet.

### `/self-review <period>` — period synthesis

1. **Resolve the period** from the argument: `H1 2026`, `2026`, `Q2 2026`,
   `last 6 months`, or `2026-01-01..2026-06-30`. If omitted, ask (default: the
   current half).
2. **Select notes** whose `date`/`date_end` span **overlaps** the window (glob +
   read frontmatter; no DB).
3. **Cluster by competency tag** — turning several small `#mentorship` notes into
   one "technical leadership" theme.
4. **Draft the review** — per theme, 1-2 short paragraphs leading with impact and
   pulling concrete numbers from `metrics`. Review-ready prose, not a note dump.
5. **Show coverage** — which notes fed each theme; flag thin/empty competencies
   and thin periods.
6. **Output to chat by default**; offer to save to
   `reviews/YYYY-self-review-<period>.md`, then remind to `/legion`.

### `/resume-bullets` — JD -> bullets (MVP, no resume needed)

JD in (pasted text / file path / URL) -> ranked, JD-worded, quantified bullets
out, each annotated by source note, plus a **Gaps — no achievement on file for
X** section. Self-contained; ships before the full tailoring command.

Engine: parse JD themes/keywords -> score each note by tag overlap (competency +
tech) and metric relevance -> rank (don't dump) -> render strong verb + what +
quantified result -> combine small same-competency notes into one pattern bullet.

**Honesty guardrail:** only facts present in notes; unmet JD requirements are
listed as gaps, never fabricated.

### `/resume` — tailor a base resume (the big goal)

Takes a JD **and** a base resume (markdown master, `resume-base.md`). Offers two
user-selectable modes; if unspecified, **asks at start, default interactive**; a
keyword in args (`interactive`/`batch`) skips the prompt.

Engine:

1. **Parse the resume into structure** — jobs -> bullets, preserving order and
   prose the tool shouldn't touch.
2. **Per existing bullet, decide an action:** **Reword** (same achievement,
   rephrased to mirror the JD / inject a matching metric), **Replace** (weak or
   irrelevant for this JD; swap in a stronger achievement under the same job), or
   **Keep**.
3. **Add** net-new bullets where a logged achievement strongly matches the JD but
   isn't represented under that job.
4. **Modes:**
   - **Interactive** — classify every bullet, show diff + rationale + source
     note, accept/reject/edit per bullet.
   - **Batch** — produce a fully tailored draft in one pass, then present the
     whole-document diff against the base.
5. **Never clobber the source** — write to `resume-drafts/<role-slug>.md`; the
   master stays pristine.

**Trust asymmetry / guardrail.** Bullets the user already wrote are trusted
prose (reword freely). Anything the tool _adds or quantifies_ must trace to a
logged achievement — same gaps-not-fabrication rule. This keeps rewording
flexible while making invention impossible, since every bullet must stay
defensible in the interview that follows.

## Build / ship order

1. `/achievement` — capture (everything else reads what it writes).
2. `/self-review` — period synthesis.
3. `/resume-bullets` — Mode A, self-contained.
4. `/resume` — tailoring, interactive + batch.

## Cross-cutting boundaries

- Commands write to the vault but never commit it; they end by reminding the
  user to run `/legion`.
- JD input modes for both resume commands: pasted text, file path, or URL.
- No fabrication anywhere downstream; gaps are surfaced explicitly.
